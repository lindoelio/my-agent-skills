# Deployment

Deploying Meteor 3 apps to production.

## Production Build

```bash
# Build for deployment (creates tarball or directory)
meteor build /path/to/output --architecture os.linux.x86_64

# With mobile
meteor build /path/to/output --server=https://myapp.com:443

# Debug build
meteor build /path/to/output --debug
```

Output:

- `.tar.gz` — server bundle (or `bundle/` directory with `--directory`)
- `.apk` — unsigned Android (if platform added)
- Xcode project — iOS (if platform added)

## Running the Bundle

```bash
cd my_build_bundle_directory
(cd programs/server && npm install)

MONGO_URL=mongodb://localhost:27017/myapp \
ROOT_URL=https://myapp.com \
PORT=3000 \
METEOR_SETTINGS='{"public":{"key":"value"}}' \
node main.js
```

> Match Node version to Meteor: `meteor node -v` (Node 22-24 for Meteor 3.x).

## Galaxy (Recommended)

```bash
DEPLOY_HOSTNAME=galaxy.meteor.com \
meteor deploy myapp.com \
  --settings settings/production.json
```

### Free tier

```bash
meteor deploy myapp.meteorapp.com --free --mongo --settings settings/production.json
```

### Container sizes

```bash
meteor deploy myapp.com --plan professional --container-size standard --settings settings/production.json
```

Sizes: `tiny`, `compact`, `standard`, `double`, `quad`, `octa`, `dozen`.

### Environment variables on Galaxy

Set via Galaxy dashboard or `--settings`:

```json
{
  "galaxy.meteor.com": {
    "env": {
      "MONGO_URL": "mongodb://...",
      "MAIL_URL": "smtps://..."
    }
  }
}
```

## Meteor Up (MUP)

```bash
meteor npm install -g mup
mup init  # creates .deploy/ with mup.js and settings.json
```

```js
// .deploy/mup.js
module.exports = {
  servers: {
    one: { host: '1.2.3.4', username: 'root' },
  },
  app: {
    name: 'myapp',
    path: '../',
    servers: { one: {} },
    buildOptions: { serverOnly: true },
    env: {
      ROOT_URL: 'https://myapp.com',
      MONGO_URL: 'mongodb://localhost:27017/myapp',
      PORT: 3000,
    },
    dockerImage: 'zodern/meteor:latest',
  },
  mongo: { version: '7.0', servers: { one: {} } },
  proxy: {
    domains: 'myapp.com',
    ssl: { letsEncryptEmail: 'admin@myapp.com' },
  },
};
```

```bash
mup deploy
```

## Docker

### `disney/meteor-base` (recommended)

```dockerfile
FROM geoffreybooth/meteor-base:3.5

COPY . /app
RUN bash $METEOR_DIR/on_build.sh

FROM node:22-alpine
COPY --from=0 /app /app
WORKDIR /app/bundle
RUN (cd programs/server && npm install)
ENV PORT=3000
EXPOSE 3000
CMD ["node", "main.js"]
```

### Build args

```bash
docker build -t myapp .
docker run -p 3000:3000 \
  -e MONGO_URL=mongodb://host.docker.internal:27017/myapp \
  -e ROOT_URL=https://myapp.com \
  myapp
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `MONGO_URL` | Yes | MongoDB connection string |
| `ROOT_URL` | Yes | Full URL to app (https://...) |
| `PORT` | Yes (bundle) | Server port (default 3000) |
| `METEOR_SETTINGS` | Optional | JSON string of settings |
| `MONGO_OPLOG_URL` | Recommended | Oplog for live queries (replica set required) |
| `MAIL_URL` | Optional | SMTP for email (smtps://user:pass@host:465) |
| `BIND_IP` | Optional | Bind IP (default 0.0.0.0) |
| `HTTP_FORWARDED_COUNT` | Optional | Proxy count for `clientAddress` |
| `DDP_TRANSPORT` | Optional | `sockjs` (default) or `uws` (3.5+) |

## MongoDB

- Use hosted MongoDB (MongoDB Atlas, Compose) for production.
- Ensure replica sets + oplog tailing.
- Same AWS region as app for latency.
- MongoDB 6+ for change streams (Meteor 3.5 default reactivity).

### Connection options via settings

```json
{
  "packages": {
    "mongo": {
      "options": {
        "tls": true,
        "tlsCAFileAsset": "certificate.pem"
      }
    }
  }
}
```

## Monitoring

- **Galaxy APM**: built-in for Galaxy deployments.
- **Monti APM**: `meteor add montiapm:agent`
- **Meteor Elastic APM**: Method/publication latency, traces.

## SEO

```bash
meteor add mdg:seo
```

```js
import { SEO } from 'meteor/mdg:seo';

SEO.set({
  title: 'My Page',
  meta: { description: 'Page description' },
  og: { image: 'https://myapp.com/og.png' },
});
```

### Prerender.io (auto on Galaxy)

For crawler rendering of client-side routes.

## CDN

```js
WebAppInternals.setBundledJsCssPrefix('https://cdn.example.com');
```

Handle webfont CORS via `WebApp.rawHandlers.use`.

## Rolling Deploys

Galaxy stops/restarts containers one-by-one. For breaking schema changes:

1. Deploy version that handles both old and new schema
2. Run migration
3. Deploy version that uses only new schema

## Continuous Deployment

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: meteorengine/setup-meteor@v1
        with:
          meteor-release: '3.5'
      - run: meteor npm install
      - run: meteor npm run test:ci
      - run: DEPLOY_HOSTNAME=galaxy.meteor.com meteor deploy myapp.com --settings settings/production.json
        env:
          METEOR_SESSION_FILE: ${{ secrets.METEOR_SESSION_FILE }}

## Portable Builds (Meteor 3.4.1+)

Build once, deploy anywhere. Omits `Meteor.isDevelopment`/`Meteor.isProduction` from the bundle:

```js
// rspack.config.js
module.exports = defineConfig(Meteor => ({
  ...Meteor.enablePortableBuild(),
}));
```

Or via `Meteor.enablePortableBuild()` in server startup.

## Service Worker / PWA (Meteor 3.4.1+)

Use Workbox with `workbox-webpack-plugin` in your `rspack.config.js`:

```js
const { GenerateSW } = require('workbox-webpack-plugin');

module.exports = defineConfig(Meteor => ({
  plugins: [
    Meteor.isClient && new GenerateSW({
      swDest: 'sw.js',
      skipWaiting: true,
      clientsClaim: true,
      exclude: [/./],
      runtimeCaching: [
        { urlPattern: /\.hot-update\./, handler: 'NetworkOnly' },
        {
          urlPattern: ({ request }) => request.mode === 'navigate',
          handler: 'NetworkFirst',
          options: { cacheName: 'pages', networkTimeoutSeconds: 15 },
        },
      ],
    }),
  ].filter(Boolean),
}));
```

## `meteor create --from` (Meteor 3.4.1+)

Create apps from GitHub, GitLab, or Bitbucket templates:

```bash
meteor create myapp --from https://github.com/user/repo
meteor create myapp --from-branch feature-branch
meteor create myapp --from-dir /path/to/local/template
```
