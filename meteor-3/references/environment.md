# Environment & Settings

## Environment Variables

| Variable | Scope | Description |
|----------|-------|-------------|
| `ROOT_URL` | dev, prod | Full URL to app (<https://myapp.com>) |
| `PORT` | prod | Server port (default 3000) |
| `MONGO_URL` | dev, prod | MongoDB connection string |
| `MONGO_OPLOG_URL` | dev, prod | Oplog URL (replica set required) |
| `MAIL_URL` | dev, prod | SMTP URL (smtps://user:pass@host:465) |
| `METEOR_SETTINGS` | prod | JSON string of settings |
| `BIND_IP` | prod | Bind IP (default 0.0.0.0) |
| `HTTP_FORWARDED_COUNT` | prod | Proxy count for clientAddress |
| `DDP_DEFAULT_CONNECTION_URL` | dev, prod | Different DDP server than ROOT_URL |
| `DDP_TRANSPORT` | dev, prod | `sockjs` (default) or `uws` (3.5+) |
| `DISABLE_WEBSOCKETS` | dev, prod | `1` to disable WebSockets |
| `DISABLE_SOCKJS` | dev, prod | `1` to use native WebSocket (alias for uws) |
| `DISABLE_SOCKJS_CORS` | dev, prod | `1` to prevent SockJS CORS headers |
| `METEOR_PACKAGE_DIRS` | dev, prod | Colon-separated local package dirs |
| `TOOL_NODE_FLAGS` | dev, prod | Flags for Node in build tool |
| `UNIX_SOCKET_PATH` | prod | UNIX socket instead of TCP port |
| `UNIX_SOCKET_GROUP` | prod | Override UNIX socket group |
| `UNIX_SOCKET_PERMISSIONS` | prod | Override UNIX socket permissions |
| `METEOR_DISABLE_OPTIMISTIC_CACHING` | prod | `1` to speed up build/deploy |
| `METEOR_PROFILE` | dev | `1` for build profiling |
| `METEOR_ENABLE_CLIENT_TOP_LEVEL_AWAIT` | dev | `true` to enable client TLA |

### Development-only (migration helpers)

| Variable | Description |
|----------|-------------|
| `WARN_WHEN_USING_OLD_API` | `true` to warn on sync API usage (2.8+) |
| `SERVER_NODE_OPTIONS` | Pass Node flags to server (e.g. `--inspect`) |

### DDP uws port (3.5+)

The `uws` transport listens on a separate port (default 5001), configurable only via settings:

```json
{
  "packages": {
    "ddp-server": {
      "transport": "uws",
      "uws": { "port": 5001, "host": "127.0.0.1", "payloadLength": 48, "timeout": 45 }
    }
  }
}
```

> For multiple instances on one host, each needs a distinct `uws.port`.

## Settings Files

### Development

```bash
meteor --settings settings/development.json
```

```json
{
  "public": {
    "appName": "My App (Dev)",
    "analyticsId": "dev-id"
  },
  "facebook": {
    "appId": "...",
    "secret": "..."
  }
}
```

### Production

```bash
# Via env var
METEOR_SETTINGS='{ "public": {...}, "private": {...} }' node main.js

# Via Galaxy deploy
meteor deploy myapp.com --settings settings/production.json
```

### Structure

```json
{
  "public": {
    "key": "value"
  },
  "packages": {
    "mongo": {
      "options": { "tls": true }
    },
    "email": {
      "service": "Mailgun",
      "user": "...",
      "password": "..."
    },
    "accounts": {
      "clientStorage": "session"
    },
    "service-configuration": {
      "google": { "clientId": "...", "secret": "..." }
    }
  }
}
```

- `public.*` — sent to client (accessible via `Meteor.settings.public`)
- Everything else — server only (accessible via `Meteor.settings`)
- `packages.<name>` — read by package config systems

### Access settings in code

```js
// Client and server
const appName = Meteor.settings.public.appName;

// Server only
const fbSecret = Meteor.settings.facebook.secret;
```

### Package options via settings

Since Meteor 1.10.2, package options go in settings under `packages.<package-name>`:

```json
{
  "packages": {
    "quave:collections": {
      "isServerOnly": true
    }
  }
}
```

## MongoDB Connection Options

```json
{
  "packages": {
    "mongo": {
      "options": {
        "tls": true,
        "tlsCAFileAsset": "certificate.pem",
        "retryWrites": true
      },
      "oplogExcludeCollections": ["products", "prices"]
    }
  }
}
```

- Keys ending in `Asset` resolve to absolute paths from `private/`.
- `oplogExcludeCollections` / `oplogIncludeCollections` — mutually exclusive.
- `Mongo.setConnectionOptions()` must be called before other Mongo packages init.

## Change Streams Configuration (3.5+)

Default reactivity uses change streams (requires MongoDB 6+ replica set). Revert to oplog:

```json
{
  "packages": {
    "mongo": {
      "reactivity": ["oplog", "polling"]
    }
  }
}
```

## File Watching (Meteor 3.3+)

Meteor 3.3 switched to `@parcel/watcher` for native file watching. If you encounter issues (WSL, network volumes, remote setups):

```bash
METEOR_WATCH_FORCE_POLLING=true meteor run
METEOR_WATCH_POLLING_INTERVAL_MS=1000 meteor run
```

## DDP Transport (Meteor 3.5)

```bash
DDP_TRANSPORT=uws meteor run       # uWebSockets (lower latency)
DDP_TRANSPORT=sockjs meteor run    # SockJS (default, max compatibility)
DISABLE_SOCKJS=true meteor run     # Drop SockJS entirely
```

## Rspack Dev Server Port (Meteor 3.4+)

```bash
RSPACK_DEVSERVER_PORT=3232 meteor run
```
