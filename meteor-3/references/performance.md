# Performance

Meteor 3.5 performance features and tuning.

## MongoDB Change Streams (3.5)

Change streams are the default reactivity mechanism in Meteor 3.5, replacing oplog tailing. They provide major resource savings and throughput improvements.

**Requirements:** MongoDB 6+ with replica set or sharded cluster. Falls back to oplog/polling automatically on older MongoDB versions.

### Benefits

- Works on managed/serverless MongoDB tiers (Atlas Shared, serverless) where oplog access isn't available
- More resilient under load — narrowly scoped subscriptions stay fast on busy collections
- Graceful fallback to oplog or polling if change streams aren't usable
- Enabled by default in 3.5 — no code changes needed

### Reverting to Oplog

```json
{
  "packages": {
    "mongo": {
      "reactivity": ["oplog", "polling"]
    }
  }
}
```

### Limitations

- Cursors using `skip`/`limit` fall back to polling
- ObjectID fields may be sent as binary when using projection with change streams (fixed in 3.5.0)

## DDP Transport (3.5)

Meteor 3.5 supports pluggable DDP transports. Switch with an environment variable or settings flag.

### SockJS (default)

Maximum compatibility for public traffic behind strict proxies. Supports long-polling fallback.

### uWebSockets (uws)

Lower latency and higher throughput for internal/controlled deployments.

```bash
DDP_TRANSPORT=uws meteor run
```

Or via settings:

```json
{
  "packages": {
    "ddp-server": {
      "transport": "uws"
    }
  }
}
```

### DISABLE_SOCKJS Mode (3.5)

Drop the SockJS layer entirely on deployments that don't need polling fallback:

```bash
DISABLE_SOCKJS=true meteor run
```

Benefits: smaller client bundle, fewer handshake round-trips, cleaner network path.

## DDP Session Resumption (3.5)

Clients automatically resume their previous connection after a temporary network disconnect. When a client reconnects within the grace period, subscriptions and in-flight method calls are preserved.

### Configuration

```js
Meteor.server.options.disconnectGracePeriod = 30000; // 30s (default 15s)
Meteor.server.options.maxMessageQueueLength = 500;   // default 100
```

### Behavior Changes

- `onConnection` is NOT called during grace-period resumption
- Use `DDP.onReconnect` on the client for reconnection logic
- Use heartbeat-based presence tracking instead of `onConnection` counting

### Presence Tracking Pattern

```js
// Server
Meteor.methods({
  async 'presence.heartbeat'() {
    if (!this.userId) return;
    await Presence.upsertAsync(
      { _id: this.userId },
      { $set: { lastSeen: new Date(), connectionId: this.connection.id } }
    );
  },
});

// Client
Meteor.startup(() => {
  const tick = () => Meteor.callAsync('presence.heartbeat');
  tick();
  Meteor.setInterval(tick, 30_000);
});
```

## WebSocket Compression (3.5)

DDP messages can be compressed with `permessage-deflate`. Enable via settings:

```json
{
  "packages": {
    "ddp-server": {
      "websocketCompression": true
    }
  }
}
```

## General Performance Tips

### File Watching (3.3+)

Meteor 3.3 switched to `@parcel/watcher` for native file watching. If you encounter issues (WSL, network volumes, remote setups), switch to polling:

```bash
METEOR_WATCH_FORCE_POLLING=true meteor run
METEOR_WATCH_POLLING_INTERVAL_MS=1000 meteor run
```

### Bundle Size

- Use `meteor run --extra-packages bundle-visualizer --production` to analyze bundle
- Enable Rspack for tree shaking and smaller bundles
- Use dynamic imports for code splitting
- Set `"modern": true` in package.json for SWC optimizations

### MongoDB Connection

- Use MongoDB 6+ with replica sets for change streams
- Same AWS region as app for latency
- Configure connection pool via settings:

```json
{
  "packages": {
    "mongo": {
      "options": {
        "maxPoolSize": 50,
        "minPoolSize": 10
      }
    }
  }
}
```

### Monitoring

- **Galaxy APM**: built-in for Galaxy deployments
- **Monti APM**: `meteor add montiapm:agent`
- **Meteor Elastic APM**: method/publication latency, traces

### Startup Optimization (3.4+)

Use `Meteor.deferDev` to defer non-critical setup in development:

```js
Meteor.startup(async () => {
  await Meteor.deferDev(connectToExternalDB);
});
```

Use `Meteor.deferProd` to defer in production:

```js
Meteor.startup(async () => {
  await Meteor.deferProd(loadDevTools);
});
```
