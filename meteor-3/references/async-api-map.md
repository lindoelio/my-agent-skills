# Async API Map (Meteor 2.x → 3.x)

Complete reference of APIs that changed from synchronous (Fibers) to asynchronous (Promises) in Meteor 3.

## Table of Contents

- [Collection Methods](#collection-methods)
- [Cursor Methods](#cursor-methods)
- [Meteor Core](#meteor-core)
- [Accounts](#accounts)
- [Email](#email)
- [Assets](#assets)
- [HTTP](#http)
- [WebApp](#webapp)
- [Removed APIs](#removed-apis)
- [Migration Patterns](#migration-patterns)

## Collection Methods

| Meteor 2.x (sync) | Meteor 3.x (async) | Notes |
|---|---|---|
| `Collection.findOne()` | `await Collection.findOneAsync()` | Throws on server if sync used |
| `Collection.insert()` | `await Collection.insertAsync()` | Returns inserted `_id` |
| `Collection.update()` | `await Collection.updateAsync()` | Returns docs affected count |
| `Collection.upsert()` | `await Collection.upsertAsync()` | Returns `{numberAffected, insertedId}` |
| `Collection.remove()` | `await Collection.removeAsync()` | Returns docs removed count |
| `Collection._ensureIndex()` | `await Collection.createIndexAsync()` | `_ensureIndex` removed |
| `Collection.createIndex()` | `await Collection.createIndexAsync()` | |
| `Collection.createCappedCollection()` | `await Collection.createCappedCollectionAsync()` | |
| `Collection.dropCollection()` | `await Collection.dropCollectionAsync()` | |
| `Collection.dropIndex()` | `await Collection.dropIndexAsync()` | |
| `Collection.countDocuments()` | `await Collection.countDocuments()` | Already returns Promise |
| `Collection.estimatedDocumentCount()` | `await Collection.estimatedDocumentCount()` | Already returns Promise |
| `Collection.rawCollection().find().toArray()` | Same (native driver, already Promise) | |

**Client exception**: sync methods (`findOne`, `find().fetch()`, etc.) still work on the client for reactivity. Use `*Async` variants on the client only when sharing isomorphic code.

## Cursor Methods

| Meteor 2.x | Meteor 3.x | Notes |
|---|---|---|
| `cursor.fetch()` | `await cursor.fetchAsync()` | Server throws on sync |
| `cursor.count()` | `await cursor.countAsync()` | |
| `cursor.forEach()` | `await cursor.forEachAsync()` | |
| `cursor.map()` | `await cursor.mapAsync()` | |
| `cursor.observe()` | `await cursor.observeAsync()` | Returns Promise of handle |
| `cursor.observeChanges()` | `await cursor.observeChangesAsync()` | Returns Promise of handle |
| `cursor[Symbol.asyncIterator]` | `for await (const doc of cursor)` | New in Meteor 3 |

```js
// Async iteration (Meteor 3)
for await (const doc of MyCollection.find({ active: true })) {
  console.log(doc._id);
}
```

## Meteor Core

| Meteor 2.x | Meteor 3.x | Notes |
|---|---|---|
| `Meteor.call('name', args)` (server) | `await Meteor.callAsync('name', args)` | Server: sync removed |
| `Meteor.call('name', args, cb)` (client) | `await Meteor.callAsync('name', args)` | Client: both work, prefer async |
| `Meteor.apply()` | `await Meteor.applyAsync()` | |
| `Meteor.user()` (server) | `await Meteor.userAsync()` | Client: `Meteor.user()` still sync/reactive |
| `Meteor.userId()` | `Meteor.userId()` | Still sync (returns string from connection context) |
| `Meteor.wrapAsync(fn)` | `util.promisify(fn)` or manual Promise | Removed |
| `Meteor.startup(fn)` | `Meteor.startup(async () => {...})` | Accepts async callbacks |

### `Meteor.callAsync` return value

`Meteor.callAsync` returns a Promise that also has `.stubPromise` and `.serverPromise` properties:

```js
const { stubPromise, serverPromise } = Meteor.callAsync('greetUser', 'John');

await stubPromise; // client simulation complete (optimistic UI populated)

try {
  await serverPromise; // server completed successfully
} catch (e) {
  console.error('Server error:', e.reason);
  // client simulation data is NOT rolled back automatically
}
```

### `Meteor.isAsyncCall`

On the server, returns `true` if the method was called via `Meteor.callAsync`:

```js
Meteor.methods({
  async foo() {
    return Meteor.isAsyncCall(); // true from Meteor.callAsync, false from Meteor.call
  },
});
```

## Accounts

| Meteor 2.x | Meteor 3.x | Notes |
|---|---|---|
| `Accounts.createUser()` | `await Accounts.createUserAsync()` | |
| `Accounts.setPassword()` | `await Accounts.setPasswordAsync()` | |
| `Accounts.addEmail()` | `await Accounts.addEmailAsync()` | |
| `Accounts.replaceEmail()` | `await Accounts.replaceEmailAsync()` | |
| `Accounts.sendResetPasswordEmail()` | `await Accounts.sendResetPasswordEmail()` | Now async |
| `Accounts.sendEnrollmentEmail()` | `await Accounts.sendEnrollmentEmail()` | Now async |
| `Accounts.sendVerificationEmail()` | `await Accounts.sendVerificationEmail()` | Now async |
| `Accounts.verifyEmail()` | `await Accounts.verifyEmail()` | Now async |
| `Accounts.forgotPassword()` | `await Accounts.forgotPassword()` | Now async |
| `Accounts.changePassword()` | `await Accounts.changePassword()` | Now async |
| `Accounts.findUserByEmail()` | `await Accounts.findUserByEmail()` | Now async |
| `Accounts.findUserByUsername()` | `await Accounts.findUserByUsername()` | Now async |
| `Accounts.setUsername()` | `await Accounts.setUsername()` | Now async |
| `Meteor.loginWithPassword()` | `Meteor.loginWithPasswordAsync()` (3.5) | Old form still works on client |
| `Meteor.loginWithToken()` | `Meteor.loginWithTokenAsync()` (3.5) | Old form still works on client |
| `Meteor.logout()` | `await Meteor.logoutAsync()` | |
| `Meteor.logoutOtherClients()` | `await Meteor.logoutOtherClientsAsync()` | |

### Accounts 3.5 additions

```js
await Meteor.loginWithPasswordAsync('alice@example.com', 'password');
await Meteor.loginWithTokenAsync(token);
await Meteor.logoutAllClientsAsync(); // log out every device
```

### Async client hooks

```js
Accounts.onLogin(async ({ user }) => {
  await Meteor.callAsync('audit.recordLogin', { userId: user._id });
});
```

> Client hooks are awaited sequentially before the originating call resolves. Keep them fast.

## Email

| Meteor 2.x | Meteor 3.x |
|---|---|
| `Email.send({...})` | `await Email.sendAsync({...})` |
| `Email.send({...}, callback)` | `await Email.sendAsync({...})` |

```js
import { Email } from 'meteor/email';

await Email.sendAsync({
  to: 'user@example.com',
  from: 'noreply@myapp.com',
  subject: 'Welcome',
  text: 'Hello!',
});
```

> Meteor 3.5 warns if `Accounts.emailTemplates.from` is not configured.

## Assets

| Meteor 2.x | Meteor 3.x |
|---|---|
| `Assets.getText(path)` | `await Assets.getTextAsync(path)` |
| `Assets.getBinary(path)` | `await Assets.getBinaryAsync(path)` |

> `Assets` cannot be imported as an ES6 module — call it directly in server code. Files must be in `private/`.

## HTTP

| Meteor 2.x | Meteor 3.x |
|---|---|
| `HTTP.call('GET', url)` | `await fetch(url)` from `meteor/fetch` |
| `HTTP.get(url)` | `await fetch(url)` |
| `HTTP.post(url, { data })` | `await fetch(url, { method: 'POST', body: JSON.stringify(data) })` |

```js
import { fetch, Headers } from 'meteor/fetch';

const response = await fetch('https://api.example.com/data', {
  headers: new Headers({ Authorization: `Bearer ${token}` }),
});
const data = await response.json();
```

## WebApp

| Meteor 2.x (Connect) | Meteor 3.x (Express 5) |
|---|---|
| `WebApp.connectHandlers.use(mw)` | `WebApp.handlers.use(mw)` |
| `WebApp.rawConnectHandlers.use(mw)` | `WebApp.rawHandlers.use(mw)` |
| `WebApp.connectApp` | `WebApp.expressApp` |

Old names kept as deprecated aliases. Express updated to v5 in Meteor 3.1.

```js
import { WebApp } from 'meteor/webapp';

const app = WebApp.express();
app.get('/hello', (req, res) => res.send('Hello'));
WebApp.handlers.use(app);
```

## Removed APIs

These are **gone entirely** in Meteor 3.x — no replacement needed, just remove:

| API | Replacement |
|---|---|
| `Promise.await(promise)` | `await promise` |
| `Meteor.wrapAsync(fn)` | `util.promisify(fn)` or `new Promise(...)` |
| `Npm.require('fibers')` | Remove — use async/await |
| `Npm.require('fibers/future')` | Remove — use `new Promise(...)` |
| `Fiber.current` | Remove |
| `Fiber.yield()` | `await` |
| `Meteor._sleepForMs(ms)` | `await Meteor.sleep(ms)` (3.4+) or `await new Promise(r => setTimeout(r, ms))` |

## Migration Patterns

### Pattern 1: `Meteor.wrapAsync` → `util.promisify`

```js
// Before
const syncFn = Meteor.wrapAsync(callbackFn);
const result = syncFn(arg1, arg2);

// After
import { promisify } from 'util';
const asyncFn = promisify(callbackFn);
const result = await asyncFn(arg1, arg2);
```

### Pattern 2: Manual Promise wrapping (non-standard callbacks)

```js
function asyncFn(arg1, arg2) {
  return new Promise((resolve, reject) => {
    callbackFn(arg1, arg2, (error, result) => {
      if (error) reject(error);
      else resolve(result);
    });
  });
}
const result = await asyncFn(arg1, arg2);
```

### Pattern 3: `Fiber/Future` → Promise

```js
// Before
const Fiber = Npm.require('fibers');
const future = new Future();
someCallback((err, res) => err ? future.throw(err) : future.return(res));
const result = future.wait();

// After
const result = await new Promise((resolve, reject) => {
  someCallback((err, res) => err ? reject(err) : resolve(res));
});
```

### Pattern 4: `bindEnvironment` still needed for external callbacks

```js
// Express middleware, setTimeout, event emitters — wrap with bindEnvironment
import { Meteor } from 'meteor/meteor';

WebApp.handlers.use('/webhook', Meteor.bindEnvironment(async (req, res) => {
  const user = await Meteor.userAsync(); // works — context preserved
  res.json({ user: user?.username });
}));
```

### Pattern 5: Tracker + async

```js
// Reactive reads AFTER await need Tracker.withComputation
Tracker.autorun(async function (computation) {
  reactiveVar1.get(); // reactive (before await)
  const docs = await MyCollection.find({}).fetchAsync();
  // reactiveVar2.get() here is NOT reactive — loses computation
  const value = Tracker.withComputation(computation, () => reactiveVar2.get()); // reactive again
});
```

### Pattern 6: Top-level await (server)

```js
// server/main.js or any server module
const Links = new Mongo.Collection('links');

const count = await Links.find().countAsync();
if (count === 0) {
  await Links.insertAsync({ url: 'https://meteor.com' });
}
```

### Detection: `WARN_WHEN_USING_OLD_API`

While migrating on Meteor 2.8+:

```bash
WARN_WHEN_USING_OLD_API=true meteor run
```

This logs warnings for every sync API call that needs migration.

### Codemod

Use the community jscodeshift codemod for bulk migration:

```bash
npx jscodeshift -t https://raw.githubusercontent.com/minhna/meteor-async-migration/main/transform.ts <files>
```
