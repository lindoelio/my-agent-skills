# Publications & Subscriptions

Publications push data from server to client over DDP. Subscriptions connect clients to publications.

## Basic Publication

```js
import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { TasksCollection } from './collection';

// Async publish function (Meteor 3)
Meteor.publish('tasks.byOwner', async function () {
  if (!this.userId) return this.ready();
  return TasksCollection.find(
    { owner: this.userId },
    {
      projection: { text: 1, completed: 1, createdAt: 1 },
      sort: { createdAt: -1 },
      limit: 100,
    }
  );
});

// With arguments
Meteor.publish('tasks.inList', async function (listId) {
  check(listId, String);
  if (!this.userId) return this.ready();
  return TasksCollection.find(
    { listId, $or: [{ owner: this.userId }, { private: false }] },
    { projection: TasksCollection.publicFields }
  );
});
```

> Use `function()` (not arrow) to access `this.userId`, `this.ready()`, etc.

## Multiple Collections

Return an array of cursors from **different** collections:

```js
Meteor.publish('listAndTasks', async function (listId) {
  check(listId, String);
  return [
    Lists.find({ _id: listId, userId: this.userId }, { projection: { name: 1 } }),
    Tasks.find({ listId }, { projection: { text: 1, completed: 1 } }),
  ];
});
```

## Subscribing (Client)

### In React

```tsx
import { useSubscribe } from 'meteor/react-meteor-data';

function TaskList({ listId }) {
  const isLoading = useSubscribe('tasks.inList', listId);
  const tasks = useTracker(() =>
    TasksCollection.find({ listId }, { sort: { createdAt: -1 } }).fetch()
  );
  if (isLoading()) return <Loading />;
  return tasks.map(t => <TaskItem key={t._id} task={t} />);
}
```

### In Blaze

```js
Template.TaskList.onCreated(function () {
  this.subscribe('tasks.inList', this.data.listId);
});

Template.TaskList.helpers({
  tasks() {
    return TasksCollection.find({ listId: this.data.listId }, { sort: { createdAt: -1 } });
  },
  isLoading() {
    return !this.subscriptionsReady();
  },
});
```

### Low-level `Meteor.subscribe`

```js
const handle = Meteor.subscribe('tasks.inList', listId, {
  onReady() { console.log('ready'); },
  onStop(err) { console.log('stopped', err); },
});

handle.ready(); // reactive boolean
handle.stop();  // unsubscribe
handle.subscriptionId; // unique ID
```

In `Tracker.autorun`, subscriptions auto-cancel on rerun. Meteor skips wasteful unsubscribe/resubscribe for identical name+params.

## Low-Level Publish API

For custom data sources (REST polling, computed counts, external DBs):

```js
Meteor.publish('countsByRoom', function (roomId) {
  check(roomId, String);
  const Counts = new Mongo.Collection('counts'); // client-side collection

  let count = 0;
  let initializing = true;

  const handle = Tasks.find({ roomId }).observeChanges({
    added: () => {
      count += 1;
      if (!initializing) this.changed('counts', roomId, { count });
    },
    removed: () => {
      count -= 1;
      if (!initializing) this.changed('counts', roomId, { count });
    },
  });

  initializing = false;
  this.added('counts', roomId, { count });
  this.ready();
  this.onStop(() => handle.stop());
});
```

### `this` methods

| Method | Description |
|--------|-------------|
| `this.added(collection, id, fields)` | Notify client of new doc |
| `this.changed(collection, id, fields)` | Notify client of changed fields |
| `this.removed(collection, id)` | Notify client of removed doc |
| `this.ready()` | Initial set complete |
| `this.onStop(fn)` | Cleanup when subscription stops (can be async in 3.4.1+) |
| `this.error(err)` | Send error to client, stop subscription |
| `this.stop()` | Stop this subscription |
| `this.userId` | Current user ID (constant per run; publish reruns on user change) |
| `this.connection` | Connection object |

## Polling External APIs

```js
Meteor.publish('polledData', async function () {
  const publishedKeys = {};
  const POLL_INTERVAL = 60000;

  const poll = async () => {
    const response = await fetch('https://api.example.com/data');
    const data = await response.json();
    data.forEach((doc) => {
      if (publishedKeys[doc._id]) {
        this.changed('externalData', doc._id, doc);
      } else {
        publishedKeys[doc._id] = true;
        this.added('externalData', doc._id, doc);
      }
    });
  };

  await poll();
  this.ready();

  const interval = Meteor.setInterval(poll, POLL_INTERVAL);
  this.onStop(() => Meteor.clearInterval(interval));
});
```

## Publication Strategies (Meteor 2.4+)

```js
import { DDPServer } from 'meteor/ddp-server';

const { SERVER_MERGE, NO_MERGE_NO_HISTORY, NO_MERGE, NO_MERGE_MULTI } =
  DDPServer.publicationStrategies;

// SERVER_MERGE (default): deltas, efficient
// NO_MERGE_NO_HISTORY: send-and-forget, no removed on stop
// NO_MERGE: remembers IDs, sends removed on stop
// NO_MERGE_MULTI: tracks multi-publication doc usage

Meteor.server.setPublicationStrategy('foo', NO_MERGE);
Meteor.server.getPublicationStrategy('foo');
```

## Relational Data

### `reywood:publish-composite`

```bash
meteor add reywood:publish-composite
```

```js
import { publishComposite } from 'meteor/reywood:publish-composite';

publishComposite('lists.withTasks', function () {
  return {
    find() {
      return Lists.find({ userId: this.userId });
    },
    children: [
      {
        find(list) {
          return Tasks.find({ listId: list._id }, { projection: { text: 1 } });
        },
      },
    ],
  };
});
```

### `tmeasday:publish-counts`

```bash
meteor add tmeasday:publish-counts
```

```js
Meteor.publish('tasksCount', function (listId) {
  Counts.publish(this, 'tasksCount', Tasks.find({ listId }), { noReady: false });
});
```

## DDP Session Resumption (Meteor 3.5)

Clients resume within `disconnectGracePeriod` after reconnect:

```js
Meteor.server.options.disconnectGracePeriod = 30000; // 30s
Meteor.server.options.maxMessageQueueLength = 500;
```

```js
import { DDP } from 'meteor/ddp-client';

DDP.onReconnect((connection) => {
  if (connection.sessionResumed) {
    console.log('Session preserved — no re-fetch needed');
  } else {
    console.log('New session established');
  }
});
```

Subscriptions auto-resume, in-flight method calls replayed. HCP is treated as graceful disconnect (skips resumption).

## Best Practices

1. **Always restrict `projection`** (or `fields`) — never publish all fields.
2. **Factor out `publicFields`** per collection for consistency:
   ```js
   Tasks.publicFields = { text: 1, completed: 1, createdAt: 1, owner: 1 };
   ```
3. **Put security in the selector**, not a pre-check — publications only rerun on `userId` change, not on data changes.
4. **Set `limit`** to cap data transfer.
5. **Whitelist filter keys** from query params.
6. **Use reactive joins** (`publish-composite`, `grapher`) for relational data.
7. **Consider Methods instead of publications** for one-shot data that doesn't need reactivity:
   ```js
   async run() {
     return await Tasks.find({}).fetchAsync();
   }
   ```

## Async `onStop` (Meteor 3.4.1+)

`onStop` callbacks can be async. The server awaits all async `onStop` callbacks before completing session cleanup:

```js
Meteor.publish('tasks.byOwner', async function () {
  const handle = await Tasks.find({ owner: this.userId }).observeChangesAsync({
    added: (id, fields) => this.added('tasks', id, fields),
    changed: (id, fields) => this.changed('tasks', id, fields),
    removed: (id) => this.removed('tasks', id),
  });

  this.onStop(async () => {
    await handle.stop();
    await someCleanupAsync();
  });

  this.ready();
});
```

## Scaling

- `cultofcoders:redis-oplog` replaces MongoDB oplog tailing with Redis pub/sub — lower CPU, finer reactivity control.
- MongoDB change streams (3.5 default) require replica set + MongoDB 6+.
- Cap `limit` and set indexes on all query selectors.
