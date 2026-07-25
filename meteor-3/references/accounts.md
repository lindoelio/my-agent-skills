# Accounts

Meteor's accounts system provides authentication, user management, and login providers.

## Setup

```bash
meteor add accounts-password          # password auth
meteor add accounts-google            # OAuth provider (one or more)
meteor add service-configuration      # configure OAuth via code
meteor add accounts-ui                # turn-key UI (Blaze) — or use useraccounts
```

## Core APIs

| API | Server | Client | Notes |
|-----|--------|--------|-------|
| `Meteor.userId()` | sync | sync | Returns string or null |
| `Meteor.user()` | `await Meteor.userAsync()` | sync (reactive) | |
| `Meteor.users` | Collection | Collection | User documents |
| `Meteor.loggingIn()` | — | sync (reactive) | Boolean |
| `Meteor.logout()` | `await Meteor.logoutAsync()` | `Meteor.logout(callback)` | |
| `Meteor.logoutOtherClients()` | `await Meteor.logoutOtherClientsAsync()` | `Meteor.logoutOtherClients(callback)` | |
| `Meteor.logoutAllClients()` | `await Meteor.logoutAllClientsAsync()` | — | 3.5: logs out every device |
| `Meteor.loginWithPassword(u, p)` | — | sync (reactive) | 3.5: `Meteor.loginWithPasswordAsync()` |
| `Meteor.loginWithToken(t)` | — | sync | 3.5: `Meteor.loginWithTokenAsync()` |

### `Meteor.user()` field selection

```js
// Client (reactive)
const name = Meteor.user({ fields: { 'profile.name': 1 } }).profile.name;

// Server (async)
const user = await Meteor.userAsync({ fields: { username: 1, emails: 1 } });
```

## User Document Schema

```js
{
  _id: String,
  username: String,          // optional
  emails: [{ address: String, verified: Boolean }], // password users
  createdAt: Date,
  profile: Object,           // client-writable by default — DON'T store secrets
  services: {                // login data — filter in publications
    password: { bcrypt: String },
    resume: { loginTokens: [...] },
    google: { ... },
  },
}
```

### Deny client writes to `profile`

```js
Meteor.users.deny({
  update() { return true; },
});
```

### Publish custom fields

```js
Meteor.publish('userData', function () {
  if (this.userId) {
    return Meteor.users.find(
      { _id: this.userId },
      { projection: { username: 1, emails: 1, role: 1, createdAt: 1 } }
    );
  }
  this.ready();
});
```

### `defaultFieldSelector` (Meteor 1.10+)

```js
Accounts.config({
  defaultFieldSelector: { username: 1, emails: 1, createdAt: 1, role: 1 },
});
```

## Password Accounts

### Create user

```js
// Server
const userId = await Accounts.createUserAsync({
  username: 'alice',
  email: 'alice@example.com',
  password: 'secret',
});

// Client — auto-logs in
await Accounts.createUserAsync({ email, password });
```

### Login

```js
// Client — sync (reactive, callback-style still works)
Meteor.loginWithPassword('alice@example.com', 'password', (err) => { });

// Client — 3.5 async
const result = await Meteor.loginWithPasswordAsync('alice@example.com', 'password');
```

### Email flows

```js
// Server — send emails (all async in 3.x)
await Accounts.sendResetPasswordEmail(userId);
await Accounts.sendEnrollmentEmail(userId);
await Accounts.sendVerificationEmail(userId);

// Client — handle tokens
Accounts.onResetPasswordLink((token, done) => {
  // show reset form, then:
  Accounts.resetPassword(token, newPassword, () => done());
});
Accounts.onEmailVerificationLink((token, done) => {
  Accounts.verifyEmail(token, done);
});
```

### Customize URLs

```js
Accounts.urls.resetPassword = (token) => {
  return Meteor.absoluteUrl(`reset-password/${token}`);
};
```

### Async URL generation (3.5+)

```js
Accounts.urls.resetPassword = async (token, extraParams) => {
  const user = await Meteor.users.findOneAsync({ 'services.password.reset.token': token });
  const domain = user?.profile?.preferredDomain || Meteor.absoluteUrl();
  return `${domain}reset-password/${token}`;
};
```

## Email Templates

```js
Accounts.emailTemplates.siteName = 'My App';
Accounts.emailTemplates.from = 'My App <noreply@myapp.com>';

Accounts.emailTemplates.resetPassword = {
  subject() { return 'Reset your password'; },
  text(user, url) {
    return `Click here to reset: ${url}`;
  },
};

Accounts.emailTemplates.enrollAccount = {
  subject(user) { return `Welcome ${user.username}!`; },
  html(user, url) { return `<p>Click <a href="${url}">here</a> to start.</p>`; },
};
```

> 3.5 warns if `from` is not configured.

## OAuth

```bash
meteor add accounts-google accounts-facebook accounts-github accounts-twitter
meteor add service-configuration
```

### Configure via code

```js
import { ServiceConfiguration } from 'meteor/service-configuration';

ServiceConfiguration.configurations.upsertAsync(
  { service: 'google' },
  {
    $set: {
      clientId: Meteor.settings.google.clientId,
      secret: Meteor.settings.google.secret,
      loginStyle: 'popup', // or 'redirect' for mobile
    },
  }
);
```

### Configure via settings

```json
{
  "packages": {
    "service-configuration": {
      "google": {
        "clientId": "...",
        "secret": "...",
        "loginStyle": "popup"
      }
    }
  }
}
```

### Login

```js
Meteor.loginWithGoogle({
  requestPermissions: ['email', 'profile'],
  requestOfflineToken: false,
}, (err) => { });
```

Property names by service: `appId` (Facebook), `clientId` (Google/GitHub/Meetup/Weibo), `consumerKey` (Twitter).

## Customizing User Creation

```js
Accounts.onCreateUser((options, user) => {
  // options comes from client — validate it
  const customized = { ...user, dexterity: Math.floor(Math.random() * 18) + 1 };
  if (options.profile) customized.profile = options.profile;
  return customized;
});
```

### Validate new users

```js
Accounts.validateNewUser((user) => {
  if (user.username && user.username.length >= 3) return true;
  throw new Meteor.Error(403, 'Username must be at least 3 characters');
});
```

### Validate login attempts

```js
Accounts.validateLoginAttempt((attempt) => {
  if (!attempt.allowed) return false;
  if (attempt.type === 'password' && !attempt.user?.emails?.[0]?.verified) {
    throw new Meteor.Error('email-not-verified', 'Verify your email first');
  }
  return true;
});
```

## Roles

```bash
meteor add alanning:roles
```

```js
Roles.addUsersToRoles(userId, ['admin'], 'group-id');
Roles.userIsInRole(userId, ['admin', 'moderator'], 'group-id');
Roles.getRolesForUser(userId);
```

For per-document permissions, use collection helpers:

```js
Lists.helpers({
  editableBy(userId) {
    return this.userId === userId || Roles.userIsInRole(userId, ['admin']);
  },
});
```

## 2FA

```bash
meteor add accounts-2fa
```

```js
// Server — generate QR
Accounts.generate2faActivationQrCode('My App', (err, { svg, secret, uri }) => {
  // send svg to client
});

// Client — enable
Accounts.enableUser2fa(codeFromAuthenticatorApp, (err) => { });

// Login with 2FA
Meteor.loginWithPasswordAnd2faCode(username, password, code, callback);
```

## Argon2 (3.5+)

```js
Accounts.config({
  argon2Enabled: true,
  argon2Type: 'argon2id',
  argon2TimeCost: 2,
  argon2MemoryCost: 19456,
  argon2Parallelism: 1,
});
```

Migration from bcrypt happens automatically on next successful login.

## HttpOnly Cookies (3.3+)

```js
Meteor.startup(() => {
  Accounts.config({
    clientStorage: 'none',
    useHttpOnlyCookies: true,
  });
});
```

Plus matching public settings:
```json
{
  "public": {
    "packages": {
      "accounts": {
        "clientStorage": "none",
        "useHttpOnlyCookies": true
      }
    }
  }
}
```

## Session Storage

```json
{
  "public": {
    "packages": {
      "accounts": {
        "clientStorage": "session"
      }
    }
  }
}
```

## accounts-express (3.5+) — Authenticated REST

```bash
meteor add accounts-express
```

```js
import { Accounts } from 'meteor/accounts-base';
import { WebApp } from 'meteor/webapp';

const app = WebApp.express();
app.get('/api/profile', Accounts.auth(), async (req, res) => {
  const user = await Meteor.userAsync(); // works — auth middleware sets context
  res.json({ user });
});
WebApp.handlers.use('/api', app);
```

Client-side `fetch` automatically sends the auth token when `accounts-express` is installed.

## Rate Limiting

Default: 5 requests per 10s per session for logins, registration, password resets.

```js
Accounts.removeDefaultRateLimit(); // remove default
Accounts.addDefaultRateLimit();    // re-add
```

## Multi-Server Accounts

```js
import { AccountsClient } from 'meteor/accounts-base';
import { DDP } from 'meteor/ddp-client';

const app2 = DDP.connect('https://api.other-server.com');
const accounts2 = new AccountsClient({ connection: app2 });

const token = Accounts._storedLoginToken();
await accounts2.loginWithToken(token);
```
