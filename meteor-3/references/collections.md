# Collections

Meteor collections wrap MongoDB with reactive live queries. In Meteor 3, all server-side write/read methods are async.

## Creating Collections

```js
import { Mongo } from 'meteor/mongo';

// Named — persisted in MongoDB, cached in Minimongo on client
const Tasks = new Mongo.Collection('tasks');

// Local — in-memory only, not synced to server
const Scratch = new Mongo.Collection(null);

// With options
const Users = new Mongo.Collection('users', {
  transform: (doc) => new User(doc), // transform docs on read
  defineMutationMethods: false, // disable client write methods (use Methods instead)
});

// TypeScript
interface Task {
  _id?: string;
  text: string;
  completed: boolean;
  owner: string;
  createdAt: Date;
}
const Tasks = new Mongo.Collection<Task>('tasks');
```

### `resolverType` option (Meteor 3.5)

Controls whether the client simulation populates Minimongo:

```js
const Greetings = new Mongo.Collection('greetUser', { resolverType: 'stub' });
// 'stub' (default): client simulation populates minimongo (optimistic UI)
// 'server': server-only promise, no client cache
```

## Schema Validation with `simpl-schema` + `collection2`

```bash
meteor npm install --save simpl-schema
meteor add aldeed:collection2
```

```js
import SimpleSchema from 'simpl-schema';
import { Mongo } from 'meteor/mongo';

const Tasks = new Mongo.Collection('tasks');

Tasks.schema = new SimpleSchema({
  text: { type: String, max: 500 },
  completed: { type: Boolean, defaultValue: false },
  owner: { type: String, regEx: SimpleSchema.RegEx.Id },
  createdAt: { type: Date, autoValue: () => new Date() },
});

Tasks.attachSchema(Tasks.schema);

// Now insertAsync/updateAsync auto-validate
await Tasks.insertAsync({ text: 'My task', owner: userId }); // validates
await Tasks.insertAsync({}); // throws ValidationError
```

> **Collection2 v4** bundles `aldeed:simple-schema` internally. Do NOT also install npm `simpl-schema` v3+ — it conflicts. Use only one.

## Collection Extensions (Meteor 3.4+)

Built into core — no package needed:

```js
// Add property to all collections
Mongo.Collection.addExtension(function (name, options) {
  this._createdAt = new Date();
});

// Add instance method
Mongo.Collection.addPrototypeMethod('softRemove', function (selector) {
  return this.updateAsync(selector, { $set: { removed: true } });
});

// Add static method
Mongo.Collection.addStaticMethod('getAllCollections', function () {
  return Array.from(Mongo._collections.values());
});
```

## Subclassing (alternative pattern)

```js
class TasksCollection extends Mongo.Collection {
  async insert(doc, callback) {
    if (!doc.createdAt) doc.createdAt = new Date();
    return super.insertAsync(doc, callback);
  }
}
const Tasks = new TasksCollection('tasks');
```

## Reading Data

### `find` — returns a cursor (reactive on client)

```js
const cursor = Tasks.find(
  { completed: false, owner: userId },
  {
    projection: { text: 1, completed: 1, createdAt: 1 }, // replaces deprecated 'fields'
    sort: { createdAt: -1 },
    limit: 50,
    skip: 0,
    collation: { locale: 'en', strength: 2 }, // case-insensitive (3.5)
    reactive: true, // default on client; set false to disable
  }
);

// Server — async
const docs = await cursor.fetchAsync();
const count = await cursor.countAsync();
await cursor.forEachAsync((doc) => console.log(doc._id));
const ids = await cursor.mapAsync((doc) => doc._id);

// Client — sync (reactive)
const docs = cursor.fetch();
const count = cursor.count();
```

### `findOne` / `findOneAsync`

```js
// Server
const task = await Tasks.findOneAsync({ _id: taskId });

// Client (reactive)
const task = Tasks.findOne(taskId);
```

### `countDocuments` / `estimatedDocumentCount`

```js
const exact = await Tasks.countDocuments({ completed: true });
const estimate = await Tasks.estimatedDocumentCount();
```

### Async iteration

```js
for await (const doc of Tasks.find({ active: true })) {
  console.log(doc._id);
}
```

## Writing Data

### `insertAsync`

```js
const id = await Tasks.insertAsync({
  text: 'New task',
  owner: this.userId,
  createdAt: new Date(),
});
```

### `updateAsync`

```js
const affected = await Tasks.updateAsync(
  taskId,
  { $set: { completed: true, completedAt: new Date() } }
);

// Multi
const affected = await Tasks.updateAsync(
  { owner: userId },
  { $set: { archived: true } },
  { multi: true }
);
```

### `upsertAsync`

```js
const result = await Stats.upsertAsync(
  { userId, date: today },
  { $set: { count: 1 }, $setOnInsert: { createdAt: new Date() } }
);
// result = { numberAffected: 1, insertedId: 'abc' }
```

### `removeAsync`

```js
const removed = await Tasks.removeAsync(taskId);
// Omit selector = no-op (safety). Use {} to remove all.
```

## Indexes

```js
// Create at startup
Meteor.startup(async () => {
  await Tasks.createIndexAsync({ owner: 1, createdAt: -1 });
  await Tasks.createIndexAsync({ email: 1 }, { unique: true });
});

// Drop
await Tasks.dropIndexAsync({ oldField: 1 });
```

### Re-create mismatched indexes

```json
{
  "packages": {
    "mongo": {
      "reCreateIndexOnOptionMismatch": true
    }
  }
}
```

## Live Queries (observe)

### `observeChanges` (efficient — deltas only)

```js
const handle = await Tasks.find({ owner: userId }).observeChangesAsync({
  added(id, fields) {
    console.log('Added:', id, fields);
  },
  changed(id, fields) {
    console.log('Changed:', id, fields);
  },
  removed(id) {
    console.log('Removed:', id);
  },
});

// Later
handle.stop();
```

### `observe` (full docs)

```js
const handle = await Tasks.find({}).observeAsync({
  addedAt(doc, atIndex, beforeId) { },
  changedAt(newDoc, oldDoc, atIndex) { },
  removedAt(doc, atIndex) { },
  movedTo(doc, fromIndex, toIndex, beforeId) { },
});
```

> In `Tracker.autorun`, observers are auto-stopped when the computation reruns. Outside autorun, call `handle.stop()` manually (typically in `onStop`).

## Raw MongoDB Driver

Access the native Node MongoDB driver for operations not supported by the Meteor API:

```js
const raw = Tasks.rawCollection();
const rawDb = Tasks.rawDatabase();

// Use aggregation, bulkWrite, etc. (all return Promises)
const results = await raw.aggregate([
  { $match: { active: true } },
  { $group: { _id: '$owner', count: { $sum: 1 } } },
]).toArray();

await raw.bulkWrite([
  { updateOne: { filter: { _id: '1' }, update: { $set: { status: 'done' } } } },
]);
```

## Connection Options

```json
{
  "packages": {
    "mongo": {
      "options": {
        "tls": true,
        "tlsCAFileAsset": "certificate.pem"
      },
      "oplogExcludeCollections": ["products", "prices"]
    }
  }
}
```

- Keys ending in `Asset` resolve to absolute paths from `private/`.
- `oplogExcludeCollections` / `oplogIncludeCollections` are mutually exclusive.
- `Mongo.setConnectionOptions()` must be called before other Mongo packages init.

## Denormalization

For counting related documents:

```js
// In a methods file or denormalizer module
import { Tasks } from './collection';
import { Lists } from '../lists/collection';

Tasks.after.insertAsync(async (userId, doc) => {
  await Lists.updateAsync(doc.listId, { $inc: { incompleteCount: 1 } });
});

Tasks.after.removeAsync(async (userId, doc) => {
  await Lists.updateAsync(doc.listId, { $inc: { incompleteCount: -1 } });
});
```

> Use `collection-hooks` package or custom method wrappers. Always use async hooks.

## Migrations

```bash
meteor add percolate:migrations
```

```js
import { Migrations } from 'meteor/percolate:migrations';

Migrations.add({
  version: 1,
  name: 'Add index to tasks',
  async up() {
    await Tasks.createIndexAsync({ owner: 1, createdAt: -1 });
  },
  async down() {
    await Tasks.dropIndexAsync({ owner: 1, createdAt: -1 });
  },
});

// Run in meteor shell or startup
Meteor.startup(() => {
  Migrations.migrateTo('latest');
});
```

## DDP Data Merging

- Same `_id` + collection from multiple subscriptions: top-level fields merged (last writer wins per field).
- Sub-fields are NOT recursively merged — arbitrary winner on conflict.
- Avoid large nested arrays in documents — split into separate collections.

## Collation (Meteor 3.5)

Locale-aware string comparison for selectors and sorting, matching MongoDB's collation feature. Supported on both client (Minimongo via `Intl.Collator`) and server.

```js
// Case-insensitive find
const users = Users.find(
  { email: 'Alice@Example.COM' },
  { collation: { locale: 'en', strength: 2 } }
).fetch();

// Locale-aware sort
const posts = Posts.find(
  {},
  { collation: { locale: 'en', strength: 2 }, sort: { title: 1 } }
).fetch();

// Back with a collation-aware index
await Users.createIndexAsync(
  { email: 1 },
  { collation: { locale: 'en', strength: 2 } }
);
```

Supported on both client and server: `locale`, `strength` (1-3), `caseLevel`, `numericOrdering`, `caseFirst`. Server-only: `alternate`, `maxVariable`, `backwards`, `strength` values 4-5.

## Minimongo Limitations

- No `findAndModify`, aggregate, map/reduce.
- `$pull` accepts only certain selectors.
- No indexes.
- Cursors are NOT snapshots — DB changes between `find` and `fetch` may or may not appear.
