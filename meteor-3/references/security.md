# Security

Security checklist for Meteor 3 applications.

## Core Principles

1. **Trust only server-side code.** Client code is public.
2. **Validate all client inputs** — method args, publication args.
3. **Never leak secrets** to the client.
4. **Use `this.userId`** — never pass userId from the client.

## Checklist

### Remove insecure packages

```bash
meteor remove insecure    # allows client writes to collections
meteor remove autopublish # publishes all data to all clients
```

### Disable client writes

```js
// If not using allow/deny rules, deny everything:
TasksCollection.deny({
  insert() { return true; },
  update() { return true; },
  remove() { return true; },
});
```

> Preferred: use Methods for all writes and never define allow/deny.

### Validate all method arguments

```js
Meteor.methods({
  async 'tasks.insert'({ text }) {
    check(text, String);
    // or: schema.validate({ text });
    if (!this.userId) throw new Meteor.Error('not-authorized');
    // ...
  },
});
```

### Validate publication arguments

```js
Meteor.publish('tasks.inList', async function (listId) {
  check(listId, String);
  if (!this.userId) return this.ready();
  return TasksCollection.find(
    { listId, owner: this.userId },
    { projection: TasksCollection.publicFields }
  );
});
```

### Restrict publication fields

Always set `projection` (or `fields`):

```js
// Factor out public fields
TasksCollection.publicFields = { text: 1, completed: 1, createdAt: 1 };

Meteor.publish('tasks.public', async function () {
  return TasksCollection.find({}, { projection: TasksCollection.publicFields });
});
```

### Security in the selector, not pre-check

Publications only rerun on `userId` change, not on data changes:

```js
// GOOD — security in selector
Meteor.publish('list', async function (listId) {
  check(listId, String);
  return Lists.find(
    { _id: listId, userId: this.userId },
    { projection: { name: 1 } }
  );
});

// BAD — pre-check that doesn't react to data changes
Meteor.publish('list', async function (listId) {
  const list = await Lists.findOneAsync({ _id: listId });
  if (list.userId !== this.userId) return this.ready();
  return Lists.find(listId); // if ownership changes, this doesn't re-run
});
```

### Rate limit methods

```bash
meteor add ddp-rate-limiter
```

```js
import { DDPRateLimiter } from 'meteor/ddp-rate-limiter';

const METHOD_NAMES = ['tasks.insert', 'tasks.update', 'tasks.remove'];

DDPRateLimiter.addRule({
  name(name) { return METHOD_NAMES.includes(name); },
  connectionId() { return true; },
}, 5, 1000);
```

### Deny `profile` writes

```js
Meteor.users.deny({
  update() { return true; },
});
```

### Keep secrets server-side

```js
// In a Method:
export const SecretAPI = {
  async computeScore(userId) {
    // secret logic
  },
};

Meteor.methods({
  async 'scores.compute'() {
    if (!this.userId) throw new Meteor.Error('not-authorized');
    if (!this.isSimulation) {
      const { SecretAPI } = require('/imports/server/secret-api.js');
      return SecretAPI.computeScore(this.userId);
    }
  },
});
```

### Secrets in settings, not source

```json
// settings/production.json
{
  "facebook": {
    "appId": "...",
    "secret": "..."
  }
}
```

Only `public.*` reaches the client. Everything else is server-only.

### OAuth secrets via `service-configuration`

```js
ServiceConfiguration.configurations.upsertAsync(
  { service: 'google' },
  { $set: { clientId: Meteor.settings.google.clientId, secret: Meteor.settings.google.secret } }
);
```

### SSL in production

Always use HTTPS. Set `ROOT_URL` to `https://`.

### HTTP headers (Helmet)

```bash
meteor npm install helmet
```

```js
import { WebApp } from 'meteor/webapp';
import helmet from 'helmet';

WebApp.handlers.use(helmet());
```

### Content Security Policy

```bash
meteor add browser-policy
```

```js
import { BrowserPolicy } from 'meteor/browser-policy';

BrowserPolicy.content.allowOriginForAll('https://cdn.example.com');
BrowserPolicy.content.disallowInlineScripts();
BrowserPolicy.content.disallowEval();
```

### Filter user publications

Never publish `services` (contains tokens, bcrypt):

```js
Meteor.publish('userData', function () {
  if (this.userId) {
    return Meteor.users.find(
      { _id: this.userId },
      { projection: { username: 1, emails: 1, role: 1 } }
    );
  }
  this.ready();
});
```

### One method per action

Don't create generic "update" methods — create specific ones:

```js
// GOOD
'tasks.toggleComplete'
'tasks.setText'
'tasks.setDueDate'

// BAD — too broad
'tasks.update' // client can update any field
```

### Idempotency

Methods are re-called on reconnect. Make them idempotent:

```js
// Good — idempotent
async 'tasks.setCompleted'({ taskId, completed }) {
  await TasksCollection.updateAsync(taskId, { $set: { completed } });
}

// Problem — $inc is not idempotent
async 'tasks.incrementViews'({ taskId }) {
  await TasksCollection.updateAsync(taskId, { $inc: { views: 1 } });
}
// Use noRetry for non-idempotent calls:
// await Meteor.applyAsync('tasks.incrementViews', [taskId], { noRetry: true });
```

### Database indexes for security

Ensure queries can't be abused:

```js
Meteor.startup(async () => {
  await Meteor.users.createIndexAsync({ 'emails.address': 1 }, { unique: true });
  await TasksCollection.createIndexAsync({ owner: 1, createdAt: -1 });
});
```

### OWASP Node.js practices

Follow [OWASP Node.js Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Nodejs_Security_Cheat_Sheet.html).

## Async DDPRateLimiter (Meteor 3.5)

Rate limiter matchers can now be async, enabling context-aware rate limiting by user role, billing tier, or feature flag:

```js
import { DDPRateLimiter } from 'meteor/ddp-rate-limiter';

DDPRateLimiter.addRule({
  type: 'method',
  name: 'tasks.insert',
}, 5, 10000); // 5 calls per 10 seconds

// Async matcher — gate by user role from DB
DDPRateLimiter.addMatcher({
  async match({ type, name, userId }) {
    if (type !== 'method') return false;
    const user = await Meteor.users.findOneAsync(userId, { fields: { role: 1 } });
    return user?.role === 'free'; // rate-limit free-tier users
  },
}, 10, 60000);
```

## `accounts-express` Auth Middleware (Meteor 3.5)

Authenticated REST endpoints with `Accounts.auth()` middleware:

```js
import { WebApp } from 'meteor/webapp';
import { Accounts } from 'meteor/accounts-base';

const app = WebApp.express();
app.get('/api/profile', Accounts.auth(), async (req, res) => {
  const user = await Meteor.userAsync();
  res.json(user);
});

WebApp.handlers.use('/api', app);
```

Client-side `fetch` automatically sends the auth token when `accounts-express` is installed.
