# Community Packages

Key community packages for Meteor 3.5 development.

## jam:method

Boilerplate-free methods with built-in schema validation and rate limiting.

```bash
meteor add jam:method
```

```js
import { createMethod } from 'meteor/jam:method';

export const insertTask = createMethod({
  name: 'tasks.insert',
  schema: {
    text: String,
    listId: { type: String, optional: true },
  },
  async run({ text, listId }) {
    if (!this.userId) throw new Meteor.Error('not-authorized');
    return TasksCollection.insertAsync({
      text,
      listId,
      owner: this.userId,
      createdAt: new Date(),
    });
  },
});
```

## meteor-rpc

Type-safe RPC alternative with Zod schemas and client/server type inference.

```bash
meteor npm install grubba-rpc
```

```ts
import { createRpc } from 'grubba-rpc';
import { z } from 'zod';

const tasksRpc = createRpc({
  name: 'tasks',
  schema: {
    insert: z.object({ text: z.string() }),
  },
  async insert({ text }) {
    return TasksCollection.insertAsync({ text, owner: this.userId, createdAt: new Date() });
  },
});
```

## cluster

Clustering for Meteor apps to utilize multiple CPU cores.

```bash
meteor add meteorhacks:cluster
```

## mongo-transactions

MongoDB transaction support for Meteor collections.

```bash
meteor add quave:mongo-transactions
```

```js
import { runTransaction } from 'meteor/quave:mongo-transactions';

await runTransaction(async (session) => {
  await TasksCollection.insertAsync({ text: 'Task 1' }, { session });
  await TasksCollection.insertAsync({ text: 'Task 2' }, { session });
});
```

## soft-delete

Soft delete (archive) support for Meteor collections.

```bash
meteor add quave:soft-delete
```

## pub-sub

Enhanced publish/subscribe utilities.

```bash
meteor add quave:pub-sub
```

## offline

Offline data persistence for Meteor apps.

```bash
meteor add quave:offline
```

## wormhole

Pass data through publications without storing in collections.

```bash
meteor add quave:wormhole
```

## mail-preview

Preview emails in development without sending them.

```bash
meteor add quave:mail-preview
```

## archive

Archive old data from collections.

```bash
meteor add quave:archive
```
