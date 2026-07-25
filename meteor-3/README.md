# meteor-3 Agent Skill

A comprehensive [Agent Skill](https://agentskills.io) for consistent, professional development with **Meteor 3.5+** — the async, Fibers-free era of Meteor.

## What This Skill Does

This skill provides AI agents (Claude Code, Cursor, OpenCode, etc.) with:

- **Deep Meteor 3.5 knowledge** — async APIs, collections, methods, publications, accounts, routing, security, testing, deployment, mobile, and package authoring
- **Scaffold scripts** — generate complete API modules, methods, publications, React/Blaze components, migrations, and settings files with correct async patterns — without burning LLM tokens on boilerplate
- **Migration tools** — scan for old sync APIs that need conversion to Meteor 3 async
- **Reference docs** — 18 detailed reference files covering every aspect of Meteor 3 development

## Quick Start

Install the skill in your agent's skills directory, then use it in any Meteor 3 project:

```bash
# Create a new Meteor 3.5 app
meteor create myapp --typescript
cd myapp

# Scaffold a complete API module
bash skills/meteor-3/scripts/scaffold-module.sh tasks --typescript --with-schema --with-tests

# Scaffold a React component
bash skills/meteor-3/scripts/scaffold-react-component.sh TaskList --typescript

# Check for old sync APIs
bash skills/meteor-3/scripts/check-async.sh
```

## Scaffold Scripts

| Script | Purpose |
|--------|---------|
| `scaffold-module.sh` | Generate collection + methods + publications + schema + tests + index |
| `scaffold-method.sh` | Append a single method to an existing module |
| `scaffold-publication.sh` | Append a publication to an existing module |
| `scaffold-react-component.sh` | Generate a React component with `useTracker` + `useSubscribe` |
| `scaffold-blaze-template.sh` | Generate a Blaze template (html + js) |
| `scaffold-migration.sh` | Generate a database migration file |
| `scaffold-settings.sh` | Generate settings.json files (dev, prod, local) |
| `check-async.sh` | Scan for sync APIs that need Meteor 3 migration |

## Reference Files

| File | Coverage |
|------|----------|
| `async-api-map.md` | Complete v2 → v3 API mapping with migration patterns |
| `collections.md` | Collections, schemas, indexes, denormalization, collation, extensions |
| `methods.md` | Methods, validation, rate limiting, `jam:method`, `stubPromise`/`serverPromise` |
| `publications.md` | Publications, subscriptions, low-level publish, strategies, async `onStop` |
| `accounts.md` | Accounts, OAuth, 2FA, email templates, roles, Argon2, HttpOnly cookies |
| `react-integration.md` | `useTracker`, `useSubscribe`, `useFind`, suspense, SSR |
| `blaze-integration.md` | Templates, async lifecycle, helpers |
| `routing.md` | Flow Router, react-router, server routes |
| `security.md` | Security checklist, CSP, rate limiting, `accounts-express` auth |
| `testing.md` | Mocha, factories, Cypress, CI, `resolverType` |
| `deployment.md` | Galaxy, MUP, Docker, `meteor build`, PWA, portable builds |
| `build-stack.md` | Rspack, SWC, CSS/SCSS/Less, aliases, PWA, portable builds |
| `performance.md` | Change streams, DDP transport, compression, monitoring, presence |
| `community-packages.md` | jam:method, meteor-rpc, cluster, transactions, soft-delete |
| `mobile-cordova.md` | Cordova config, plugins, HCP, store builds |
| `packages.md` | Atmosphere, npm, build plugins |
| `environment.md` | Environment variables, settings files, file watching |
| `cli-reference.md` | All `meteor` CLI commands |

## Skill Structure

```text
meteor-3/
├── SKILL.md              # Main skill file (always loaded when skill triggers)
├── references/           # Detailed docs (loaded on demand)
│   ├── async-api-map.md
│   ├── collections.md
│   ├── methods.md
│   ├── publications.md
│   ├── accounts.md
│   ├── react-integration.md
│   ├── blaze-integration.md
│   ├── routing.md
│   ├── security.md
│   ├── testing.md
│   ├── deployment.md
│   ├── build-stack.md
│   ├── performance.md
│   ├── community-packages.md
│   ├── mobile-cordova.md
│   ├── packages.md
│   ├── environment.md
│   └── cli-reference.md
├── scripts/              # Scaffold scripts (executable)
│   ├── scaffold-module.sh
│   ├── scaffold-method.sh
│   ├── scaffold-publication.sh
│   ├── scaffold-react-component.sh
│   ├── scaffold-blaze-template.sh
│   ├── scaffold-migration.sh
│   ├── scaffold-settings.sh
│   └── check-async.sh
└── assets/               # Templates
    ├── package-json-template.json
    ├── tsconfig-template.json
    ├── client-main.js
    ├── server-main.js
    ├── startup-client-index.js
    ├── startup-server-index.js
    ├── fixtures.js
    ├── routes.js
    └── mobile-config-template.js
```

## Meteor 3.5 Highlights

- **Modern Build Stack** — Rspack + SWC (4x faster builds, 8x smaller bundles)
- **Fibers removed** — all server APIs are async (`findOneAsync`, `insertAsync`, `Meteor.callAsync`, `Meteor.userAsync`)
- **Node.js 24.15**, Express 5, MongoDB driver 6.x
- **MongoDB Change Streams** as default reactivity (MongoDB 6+)
- **DDP Session Resumption** — clients resume after reconnect
- **Pluggable DDP Transport** — `uws` for lower latency
- **`accounts-express`** — authenticated REST endpoints
- **Argon2 password hashing**
- **Async DDPRateLimiter rules**
- **MongoDB Collation support**
- **Collection Extensions in core**
- **Service Worker / PWA support**

## License

MIT
