# Methods

Methods are Meteor's RPC system — the recommended way to write data from the client. Define them in common code (client+server) for Optimistic UI, or server-only for security.

## Basic Pattern (Meteor 3 async)

```js
import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { TasksCollection } from './collection';

Meteor.methods({
  async 'tasks.insert'({ text }) {
    check(text, String);
    if (!this.userId) {
      throw new Meteor.Error('not-authorized', 'You must be logged in');
    }
    return TasksCollection.insertAsync({
      text,
      owner: this.userId,
      createdAt: new Date(),
    });
  },
});
```

## The `this` Context

| Property | Type | Description |
|----------|------|-------------|
| `this.userId` | String\|null | Current user's ID (server) |
| `this.setUserId(id)` | Function | Change user for this connection's future calls |
| `this.isSimulation` | Boolean | True on client stub |
| `this.unblock()` | Function | Allow other methods to run while this one continues |
| `this.connection` | Object | Connection object (server) |
| `this.randomSeed` | Number | Deterministic RNG seed for client/server parity |

> Never pass `userId` from the client — always use `this.userId`.

## Validation with `check`

```js
import { check, Match } from 'meteor/check';

Meteor.methods({
  async 'tasks.update'({ taskId, newText, tags }) {
    check(taskId, String);
    check(newText, String);
    check(tags, Match.Maybe([String]));

    // ... logic
  },
});
```

### Common `Match` patterns

| Pattern | Matches |
|---------|---------|
| `String`, `Number`, `Boolean` | Primitive types |
| `Match.Integer` | 32-bit integer |
| `Match.Any` | Anything |
| `Match.Maybe(pattern)` | `undefined`, `null`, or pattern |
| `Match.Optional(pattern)` | Absent or pattern (rejects `null`) |
| `Match.OneOf(p1, p2)` | Union |
| `Match.ObjectIncluding({...})` | Object with at least these keys |
| `Match.Where(fn)` | Custom validator |
| `[pattern]` | Array of matching elements |

## Validation with `simpl-schema` (recommended for complex schemas)

```js
import SimpleSchema from 'simpl-schema';

const InsertSchema = new SimpleSchema({
  text: { type: String, max: 500 },
  listId: { type: String, regEx: SimpleSchema.RegEx.Id },
  tags: { type: Array, optional: true },
  'tags.$': { type: String },
});

Meteor.methods({
  async 'tasks.insert'(args) {
    InsertSchema.validate(args);
    // ... logic
  },
});
```

## `jam:method` (recommended — boilerplate-free)

```bash
meteor add jam:method
meteor npm install simpl-schema
```

```js
import { createMethod } from 'meteor/jam:method';
import SimpleSchema from 'simpl-schema';
import { TasksCollection } from './collection';

export const taskInsert = createMethod({
  name: 'tasks.insert',
  schema: new SimpleSchema({
    text: { type: String, max: 500 },
  }),
  rateLimit: { limit: 5, interval: 1000 }, // built-in rate limiting
  async run({ text }) {
    if (!this.userId) throw new Meteor.Error('not-authorized');
    return TasksCollection.insertAsync({
      text,
      owner: this.userId,
      createdAt: new Date(),
    });
  },
});

// Client call
const id = await taskInsert.call({ text: 'My task' });
```

Benefits: auto schema validation, auto rate limiting, callable via `.call()`, exportable, testable.

## Calling Methods

### Client

```js
// Promise-based (recommended)
const result = await Meteor.callAsync('tasks.insert', { text: 'My task' });

// With stub/server promises
const { stubPromise, serverPromise } = Meteor.callAsync('tasks.insert', { text: 'My task' });
await stubPromise; // optimistic UI applied
try {
  await serverPromise; // server confirmed
} catch (e) {
  console.error(e.reason);
}
```

### Server (call directly)

On the server, prefer calling the function directly rather than `Meteor.callAsync`:

```js
// Instead of await Meteor.callAsync('tasks.insert', { text: 'foo' })
// Just import and call the function
import { taskInsert } from '/imports/api/tasks/methods';
const id = await taskInsert.run.call({ userId: systemUserId }, { text: 'foo' });
```

## Error Handling

```js
throw new Meteor.Error('error-code', 'Human-readable reason', { details: 'optional' });
```

Only `Meteor.Error` is sent to the client verbatim. Other exceptions are sanitized to `Meteor.Error(500, 'Internal server error')` unless they have a `.sanitizedError` property that is a `Meteor.Error`.

### Validation errors

```js
import { ValidationError } from 'meteor/mdg:validated-method';
// or from simpl-schema
throw new ValidationError([{ name: 'text', type: 'required' }], 'Text is required');
```

## Rate Limiting

```bash
meteor add ddp-rate-limiter
```

```js
import { DDPRateLimiter } from 'meteor/ddp-rate-limiter';

const METHOD_NAMES = [
  'tasks.insert',
  'tasks.update',
  'tasks.remove',
];

DDPRateLimiter.addRule({
  name(name) {
    return METHOD_NAMES.includes(name);
  },
  connectionId() { return true; },
}, 5, 1000); // 5 calls per second per connection
```

### Async rate limiters (Meteor 3.5)

```js
const adminRule = {
  type: 'method',
  name: 'admin.action',
  async userId(userId) {
    const user = await Meteor.users.findOneAsync(userId);
    return user?.role !== 'admin';
  },
};
DDPRateLimiter.addRule(adminRule, 1, 60000);

// Custom error message
const ruleId = DDPRateLimiter.addRule(adminRule, 1, 60000);
DDPRateLimiter.setErrorMessageOnRule(ruleId, (data) =>
  `Too many attempts. Try again in ${Math.ceil(data.timeToReset / 1000)}s.`
);
```

## Optimistic UI

Methods defined in common code run a **stub** on the client (simulation) before the server executes. This makes the UI feel instant.

- Stub return values are ignored — run for side effects (local DB writes).
- On server result, stub writes are rolled back and replaced with server data.
- `this.isSimulation` is `true` in the stub.

### Async stub limitations

Async stubs cannot use:

- `fetch` / XMLHttpRequest
- `setTimeout` / `setImmediate`
- `indexedDB`, web workers
- Any macrotask-based async

Violation warning: `Method stub (<name>) took too long and could cause unexpected problems.`

## Idempotency

Methods are re-called on reconnect. Make them idempotent except for `$inc`/`$push` and external API calls. Use `noRetry` for non-idempotent operations:

```js
await Meteor.applyAsync('charge.card', [cardId, amount], { noRetry: true });
```

## Advanced: ValidatedMethod pattern

```js
import { ValidatedMethod } from 'meteor/mdg:validated-method';

export const taskInsert = new ValidatedMethod({
  name: 'tasks.insert',
  validate: new SimpleSchema({
    text: { type: String, max: 500 },
  }).validator(),
  async run({ text }) {
    if (!this.userId) throw new Meteor.Error('not-authorized');
    return TasksCollection.insertAsync({ text, owner: this.userId, createdAt: new Date() });
  },
});

// Client
const id = await taskInsert.call({ text: 'My task' });
```

## Security Rules

1. Never use `allow/deny` for security — use Methods.
2. If you must disable client writes: `Collection.deny({ update() { return true; } })`.
3. Validate all arguments with `check` or `simpl-schema`.
4. Use `this.userId`, never trust client-passed userId.
5. One method per specific action (don't create generic "update" methods).
6. Rate limit method calls.
7. Keep secret logic server-only: put in `server/` or `require()` inside `if (!this.isSimulation)`.

## `Meteor.isAsyncCall`

On the server, returns `true` if the method was called via `Meteor.callAsync`:

```js
Meteor.methods({
  async foo() {
    return Meteor.isAsyncCall(); // true from callAsync, false from call
  },
});
```

## `stubPromise` and `serverPromise`

`Meteor.callAsync` returns a Promise with `.stubPromise` and `.serverPromise` properties:

```js
const { stubPromise, serverPromise } = Meteor.callAsync('greetUser', 'John');

await stubPromise; // client simulation complete (Optimistic UI populated)

try {
  await serverPromise; // server completed successfully
} catch (e) {
  console.error('Server error:', e.reason);
}
```

## `Meteor.applyAsync`

Like `Meteor.apply` but async, with support for async stubs:

```js
const result = await Meteor.applyAsync('tasks.insert', [{ text: 'Hello' }], {
  returnStubValue: true,
  throwStubExceptions: true,
});
```
