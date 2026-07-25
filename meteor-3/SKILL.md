---
name: meteor-3
description: |
  Use this skill whenever building, modifying, planning, scaffolding, testing, or debugging Meteor 3.x applications (Meteor 3.0 through 3.5+). Triggers on requests involving Meteor, Meteor.js, DDP, Minimongo, Atmosphere packages, `meteor create`, Blaze, Tracker, `Meteor.methods`, `Meteor.publish`, `Mongo.Collection`, `Meteor.callAsync`, `findOneAsync`, `insertAsync`, `updateAsync`, or any Meteor 3.x API. Also use when the user mentions Galaxy, MUP, Cordova with Meteor, or is migrating from Meteor 2.x (Fibers) to 3.x (async/await). Covers full-stack reactive architecture, collections/methods/publications, accounts, routing, security, testing, deployment, mobile, and package authoring. Provides scaffold scripts for fast, token-efficient agentic coding. Do NOT use for non-Meteor Node.js apps or Meteor 1.x/2.x projects that have not begun async migration.
license: MIT
compatibility: Meteor 3.0+ (Node 22-24.15), MongoDB 6+ required for change streams
metadata:
  author: agent-skills
  version: "1.1"
  meteor-version: "3.5"
  tags: [meteor, fullstack, ddp, mongodb, async, rspack]
---

# Meteor 3 Developer Skill

Meteor 3 is a full-stack JavaScript platform built on Node 22-24.15, Express 5, and MongoDB driver 6.x. The defining change from Meteor 2 is the **removal of Fibers**: all server-side APIs that were synchronous are now `async` and return Promises. This skill targets Meteor 3.5+ and assumes async-first patterns throughout. New apps use the **modern build stack** (Rspack + SWC) by default.

## Gotchas (read these first)

1. **Server collections are async-only.** `findOne`, `insert`, `update`, `remove`, `fetch`, `count`, `forEach`, `map`, `observe`, `observeChanges` all throw on the server. Use the `*Async` variants: `findOneAsync`, `insertAsync`, `updateAsync`, `removeAsync`, `fetchAsync`, `countAsync`, `forEachAsync`, `mapAsync`, `observeAsync`, `observeChangesAsync`. On the **client**, sync methods still work for reactivity — only use `*Async` on the client when sharing isomorphic code.

2. **`Meteor.call` → `Meteor.callAsync`.** On the client, use `await Meteor.callAsync('name', ...args)` for any method with an async stub. `Meteor.call` still works for sync-stub methods but logs a warning otherwise. On the server, `Meteor.call` is gone — use `Meteor.callAsync` or call the function directly.

3. **`Meteor.user()` is async on the server.** Use `await Meteor.userAsync()`. On the client, `Meteor.user()` is still synchronous and reactive.

4. **`Meteor.wrapAsync` is removed.** Convert callback APIs with `util.promisify` or wrap in `new Promise(...)`.

5. **`HTTP.call` is deprecated.** Use `import { fetch } from 'meteor/fetch'` (WHATWG fetch).

6. **`Email.send` is removed.** Use `await Email.sendAsync({...})`.

7. **`Assets.getText` / `Assets.getBinary` are removed.** Use `await Assets.getTextAsync(path)` / `await Assets.getBinaryAsync(path)`.

8. **`WebApp.connectHandlers` → `WebApp.handlers`.** Express 5 replaced Connect. `WebApp.rawConnectHandlers` → `WebApp.rawHandlers`. `WebApp.connectApp` → `WebApp.expressApp`.

9. **`Accounts.setPassword` → `Accounts.setPasswordAsync`.** `Accounts.addEmail` → `Accounts.addEmailAsync`. Many accounts methods are now async — see `references/async-api-map.md`.

10. **Tracker + async gotcha.** In `Tracker.autorun(async fn)`, code after the first `await` loses reactivity. Wrap reactive reads in `Tracker.withComputation(computation, () => ...)` to restore it. The `react-meteor-data` `useTracker` hook handles this internally.

11. **`bindEnvironment` is still needed** for callbacks from external libraries (Express middleware, `setTimeout`, etc.) to preserve Meteor context. Use `Meteor.bindEnvironment(fn)`.

12. **Top-level await is enabled on the server by default.** Enable on client with `METEOR_ENABLE_CLIENT_TOP_LEVEL_AWAIT=true` (breaks `client/compatibility` and HMR — test carefully).

13. **MongoDB change streams are the default reactivity mechanism in 3.5.** Requires MongoDB 6+ with replica set. Falls back to oplog/polling automatically. Revert via settings: `"packages": { "mongo": { "reactivity": ["oplog", "polling"] } }`.

14. **DDP session resumption changes `onConnection` behavior (3.5).** Clients resume within `disconnectGracePeriod` (default 15s) without triggering `onConnection` again. Use `DDP.onReconnect` on the client and heartbeat-based presence tracking instead of `onConnection` counting. See `references/performance.md`.

15. **Rspack is the default bundler for new apps (3.4+).** New apps use the modern build stack (Rspack + SWC) by default. Existing apps enable it with `meteor add rspack` and `"modern": true` in `package.json`. Rspack requires entry points in `meteor.mainModule` and does not support nested imports. See `references/build-stack.md`.

## Quick Start

Create a new app and run it:

```bash
meteor create myapp          # React + MongoDB (default)
meteor create myapp --blaze  # Blaze + MongoDB
meteor create myapp --vue    # Vue 3 + Rspack
meteor create myapp --svelte # Svelte + Rspack
meteor create myapp --solid  # Solid + Rspack
meteor create myapp --typescript  # React + TypeScript
meteor create myapp --tailwind    # React + Tailwind CSS
meteor create myapp --apollo # React + Apollo GraphQL
cd myapp
meteor npm install
meteor                       # runs on http://localhost:3000
```

Create a full imports-based structure (recommended for real apps):

```bash
meteor create myapp --full
```

## Scaffold Scripts (token-efficient code generation)

This skill bundles scripts that generate consistent, idiomatic Meteor 3 code. **Always prefer these scripts over hand-writing boilerplate** — they produce correct async patterns, naming conventions, and file structure without burning LLM tokens on repetitive code.

Run scripts from the project root (where `.meteor/` lives).

### `scripts/scaffold-module.sh` — Generate a complete API module

Generates a collection, methods, publications, schema, tests, and index file for a domain entity in `imports/api/`:

```bash
bash scripts/scaffold-module.sh <entity-name> [--typescript] [--with-schema] [--with-tests]
# Example:
bash scripts/scaffold-module.sh tasks --typescript --with-schema --with-tests
# Creates: imports/api/tasks/{collection.ts, methods.ts, publications.ts, schema.ts, tasks.tests.ts, index.ts}
```

### `scripts/scaffold-method.sh` — Generate a single method

```bash
bash scripts/scaffold-method.sh <entity> <action> [--typescript]
# Example:
bash scripts/scaffold-method.sh tasks insert --typescript
# Appends an async insert method to imports/api/tasks/methods.ts
```

### `scripts/scaffold-publication.sh` — Generate a publication

```bash
bash scripts/scaffold-publication.sh <entity> <publication-name> [--typescript]
# Example:
bash scripts/scaffold-publication.sh tasks tasks.byOwner --typescript
```

### `scripts/scaffold-react-component.sh` — Generate a React + Meteor data component

```bash
bash scripts/scaffold-react-component.sh <ComponentName> [--typescript]
# Example:
bash scripts/scaffold-react-component.sh TaskList --typescript
# Creates: imports/ui/components/TaskList.tsx with useTracker + useSubscribe
```

### `scripts/scaffold-blaze-template.sh` — Generate a Blaze template (html + js)

```bash
bash scripts/scaffold-blaze-template.sh <template_name>
# Example:
bash scripts/scaffold-blaze-template.sh task_item
# Creates: imports/ui/tasks/task_item.html and task_item.js
```

### `scripts/scaffold-migration.sh` — Generate a migration file

```bash
bash scripts/scaffold-migration.sh <version> <description>
# Example:
bash scripts/scaffold-migration.sh 2 add-index-to-tasks
# Creates: imports/api/migrations/2_add-index-to-tasks.js
```

### `scripts/scaffold-settings.sh` — Generate settings.json files

```bash
bash scripts/scaffold-settings.sh
# Creates: settings/development.json, settings/production.json with Meteor 3 defaults
```

### `scripts/check-async.sh` — Scan for old sync APIs (migration helper)

```bash
bash scripts/check-async.sh
# Scans server/ and imports/ for sync collection methods, Meteor.call, etc.
# Outputs a report of lines that need migration to *Async variants
```

## Navigating the Skill

Read these reference files based on the task:

| Task | Reference file |
|------|---------------|
| Async API mapping (v2 → v3), migration patterns | `references/async-api-map.md` |
| Collections, schemas, indexes, denormalization, collation | `references/collections.md` |
| Methods, validation, rate limiting, `jam:method` | `references/methods.md` |
| Publications, subscriptions, low-level publish, strategies | `references/publications.md` |
| Accounts, OAuth, 2FA, email templates, roles, HttpOnly cookies | `references/accounts.md` |
| React integration (`useTracker`, `useSubscribe`, suspense) | `references/react-integration.md` |
| Blaze integration (async helpers, templates) | `references/blaze-integration.md` |
| Routing (Flow Router, server routes, dynamic imports) | `references/routing.md` |
| Security checklist, allow/deny, rate limiting, CSP, `accounts-express` | `references/security.md` |
| Testing (Mocha, factories, Cypress, CI) | `references/testing.md` |
| Deployment (Galaxy, MUP, Docker, `meteor build`, PWA) | `references/deployment.md` |
| Modern build stack (Rspack, SWC, CSS, aliases, PWA) | `references/build-stack.md` |
| Performance (change streams, DDP transport, compression, monitoring) | `references/performance.md` |
| Community packages (jam:method, meteor-rpc, cluster, transactions) | `references/community-packages.md` |
| Mobile / Cordova (config, plugins, HCP, build) | `references/mobile-cordova.md` |
| Package authoring (Atmosphere, npm, build plugins) | `references/packages.md` |
| Environment variables and settings | `references/environment.md` |
| CLI commands reference | `references/cli-reference.md` |

## Project Structure (Meteor 3 recommended)

```text
myapp/
├── .meteor/
├── client/
│   ├── main.html           # <head>, <body> with #app
│   └── main.js             # eager entry: import '/imports/startup/client'
├── server/
│   └── main.js             # eager entry: import '/imports/startup/server'
├── imports/
│   ├── startup/
│   │   ├── client/
│   │   │   ├── index.js
│   │   │   ├── routes.js
│   │   │   └── useraccounts-configuration.js
│   │   └── server/
│   │       ├── index.js
│   │       ├── fixtures.js
│   │       └── register-api.js
│   ├── api/
│   │   └── tasks/
│   │       ├── collection.ts
│   │       ├── schema.ts
│   │       ├── methods.ts
│   │       ├── publications.ts
│   │       ├── tasks.tests.ts
│   │       └── index.ts
│   └── ui/
│       ├── components/
│       ├── layouts/
│       └── pages/
├── public/                 # static assets served as-is
├── private/                # server-only assets (Assets.getTextAsync)
├── settings/
│   ├── development.json
│   └── production.json
├── mobile-config.js        # Cordova config (if mobile)
├── package.json
└── tsconfig.json           # if TypeScript
```

**Key rules:**

- `client/` and `server/` are eager entry points — keep them thin (one import line).
- Everything else goes in `imports/` (lazily loaded, tree-shakeable).
- Set `meteor.mainModule` in `package.json` for explicit entry points:

```json
{
  "meteor": {
    "mainModule": {
      "client": "client/main.js",
      "server": "server/main.js"
    }
  }
}
```

## Core Async Patterns (Meteor 3)

### Collection CRUD

```js
// Server — always use *Async
const doc = await MyCollection.findOneAsync({ _id: '123' });
const id = await MyCollection.insertAsync({ name: 'foo', createdAt: new Date() });
await MyCollection.updateAsync(id, { $set: { name: 'bar' } });
await MyCollection.removeAsync(id);
const docs = await MyCollection.find({ active: true }).fetchAsync();
const count = await MyCollection.find({}).countAsync();
await MyCollection.createIndexAsync({ email: 1 }, { unique: true });

// Client — sync still works (for reactivity), *Async for isomorphic code
const doc = MyCollection.findOne('123'); // reactive, sync on client
const docs = MyCollection.find({}).fetch(); // reactive cursor fetch
```

### Methods (RPC)

```js
// imports/api/tasks/methods.ts
import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { TasksCollection } from './collection';

Meteor.methods({
  async 'tasks.insert'({ text, userId }) {
    check(text, String);
    check(userId, String);
    if (!this.userId) throw new Meteor.Error('not-authorized');
    return TasksCollection.insertAsync({
      text,
      owner: this.userId,
      createdAt: new Date(),
    });
  },
  async 'tasks.toggleComplete'({ taskId }) {
    check(taskId, String);
    const task = await TasksCollection.findOneAsync(taskId);
    if (!task) throw new Meteor.Error('not-found');
    if (task.owner !== this.userId) throw new Meteor.Error('not-authorized');
    return TasksCollection.updateAsync(taskId, { $set: { completed: !task.completed } });
  },
});

// Client call
const result = await Meteor.callAsync('tasks.insert', { text: 'My task', userId: Meteor.userId() });
```

### Publications

```js
// imports/api/tasks/publications.ts
import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check';
import { TasksCollection } from './collection';

Meteor.publish('tasks.byOwner', async function () {
  if (!this.userId) return this.ready();
  return TasksCollection.find(
    { owner: this.userId },
    { projection: { text: 1, completed: 1, createdAt: 1 } }
  );
});
```

### React with Meteor data

```tsx
import { useTracker, useSubscribe } from 'meteor/react-meteor-data';
import { TasksCollection } from '/imports/api/tasks/collection';

function TaskList() {
  const isLoading = useSubscribe('tasks.byOwner');
  const tasks = useTracker(() =>
    TasksCollection.find({}, { sort: { createdAt: -1 } }).fetch()
  );

  if (isLoading()) return <Loading />;
  return tasks.map(t => <TaskItem key={t._id} task={t} />);
}
```

### Express middleware (WebApp)

```js
import { WebApp } from 'meteor/webapp';
import { Meteor } from 'meteor/meteor';

WebApp.handlers.use('/api/health', Meteor.bindEnvironment(async (req, res) => {
  const user = await Meteor.userAsync();
  res.json({ status: 'ok', user: user?.username });
}));
```

## Key Packages (Meteor 3.5)

| Package | Purpose |
|---------|---------|
| `meteor-base` | Core bundle (autoupdate, hot-code-push, etc.) |
| `mongo` | MongoDB collections + change streams |
| `rspack` | Rspack bundler integration (default for new apps in 3.4+) |
| `accounts-password` | Password auth (Argon2 support since 3.0) |
| `accounts-express` | Authenticated REST endpoints via `Accounts.auth()` middleware (3.5) |
| `accounts-google/facebook/github` | OAuth providers |
| `react-meteor-data` | `useTracker`, `useSubscribe`, `useFind` hooks |
| `ecmascript` | Babel ES2015+ transpilation |
| `typescript` | TypeScript support |
| `hot-module-replacement` | HMR for React/Blaze/Svelte/Vue |
| `fetch` | WHATWG `fetch()` polyfill (replaces `http`) |
| `email` | `Email.sendAsync()` via Nodemailer |
| `check` | Argument validation |
| `ddp-rate-limiter` | Rate limit methods/subscriptions (async matchers in 3.5) |
| `ostrio:flow-router-extra` | Client routing (recommended) |
| `jam:method` | Boilerplate-free methods with schema + rate limiting |
| `grubba-rpc` | Type-safe RPC with Zod schemas and client/server type inference |
| `aldeed:collection2` | Schema-validated collections (v4 bundles simple-schema) |
| `meteortesting:mocha` | Test runner |
| `percolate:migrations` | Database migrations |
| `cultofcoders:redis-oplog` | Redis-based reactivity (scales better than oplog) |

## When the user asks to build a Meteor feature

1. **Check if a scaffold script covers it** — run the script first, then customize.
2. **Always use async server-side** — `*Async` collection methods, `Meteor.callAsync`, `await Meteor.userAsync()`.
3. **Validate inputs** — `check()` or `simpl-schema` in every method and publication.
4. **Use `this.userId`** — never pass userId from the client.
5. **Restrict publication fields** — always set `projection` (or `fields`).
6. **Check if Rspack is configured** — new apps use Rspack by default; existing apps may need `meteor add rspack` and `"modern": true` in `package.json`.
7. **Read the relevant reference file** for detailed API signatures and edge cases.
8. **Run `meteor lint`** to catch issues after changes.
9. **Test with `meteor test --driver-package meteortesting:mocha`**.

## Meteor 3.5 Highlights

- **Modern Build Stack**: Rspack bundler integration (3.4+) + SWC transpiler (3.3+) — 4x faster builds, 8x smaller bundles. New apps use this by default. See `references/build-stack.md`.
- **MongoDB Change Streams** as default reactivity (MongoDB 6+ required). Major resource savings, works on serverless/Atlas Shared tiers. See `references/performance.md`.
- **DDP Session Resumption**: clients resume within `disconnectGracePeriod` (default 15s) after reconnect. `onConnection` is NOT called on resume — use `DDP.onReconnect` and heartbeat-based presence.
- **Pluggable DDP Transport**: `DDP_TRANSPORT=uws` for lower latency, `DISABLE_SOCKJS=true` to drop SockJS entirely.
- **`accounts-express`**: authenticated REST endpoints via `Accounts.auth()` middleware.
- **Async DDPRateLimiter rules**: matchers can be async (fetch from DB to gate by role/tier).
- **MongoDB Collation**: case-insensitive queries via `{ collation: { locale, strength } }` on both client and server.
- **Argon2 password hashing** (3.0+): `Accounts.config({ argon2Enabled: true })`.
- **`Meteor.loginWithPasswordAsync`** / **`Meteor.loginWithTokenAsync`** / **`Meteor.logoutAllClientsAsync`**.
- **Collection Extensions in core** (3.4): `Mongo.Collection.addExtension`, `addPrototypeMethod`, `addStaticMethod`.
- **`Meteor.deferDev` / `Meteor.deferProd`** (3.4): defer non-critical setup per environment.
- **HttpOnly cookies for accounts** (3.3): `Accounts.config({ useHttpOnlyCookies: true })`.
- **Service Worker / PWA support** (3.4.1): Workbox integration via Rspack.
- **Node.js 24.15**, Express 5, MongoDB driver 6.x.
