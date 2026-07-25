# CLI Reference

## `meteor create`

```bash
# Without args: interactive wizard
meteor create

# Application types
meteor create <app-name>                    # React + MongoDB (default)
meteor create <app-name> --react            # React (same as default)
meteor create <app-name> --blaze            # Blaze + MongoDB
meteor create <app-name> --vue              # Vue 3 + Rspack
meteor create <app-name> --svelte           # Svelte + Rspack
meteor create <app-name> --solid            # Solid + Rspack
meteor create <app-name> --typescript       # React + TypeScript
meteor create <app-name> --typescript-tailwind  # React + TypeScript + Tailwind
meteor create <app-name> --tailwind         # React + Tailwind CSS
meteor create <app-name> --chakra-ui        # React + Chakra UI
meteor create <app-name> --apollo           # React + Apollo GraphQL
meteor create <app-name> --angular          # Angular + Rspack (experimental)
meteor create <app-name> --babel            # Babel instead of SWC
meteor create <app-name> --coffeescript     # CoffeeScript

# Project structure
meteor create <app-name> --bare             # Empty Blaze (minimal)
meteor create <app-name> --full             # Full imports-based structure
meteor create <app-name> --minimal          # Minimal packages
meteor create <app-name> --prototype        # With autopublish + insecure

# From templates
meteor create <app-name> --release 3.5      # Specific Meteor version
meteor create <app-name> --from <url>       # From GitHub/GitLab/Bitbucket template
meteor create <app-name> --from-branch <b>  # From specific branch
meteor create <app-name> --from-dir <path>  # From local template directory

# From community examples
meteor create <app-name> --example <slug>   # Create from community example
meteor create --list                        # List available examples

# Package
meteor create --package <username:name>     # New package
```

## `meteor run`

```bash
meteor                                     # Run on localhost:3000
meteor run --port 4000                     # Custom port (MongoDB on 4001)
meteor run --port 192.168.1.100:3000       # Bind to IP
meteor run --open                          # Open browser
meteor run --production                    # Production mode (DON'T use for real prod)
meteor run --release 3.5                   # Specific release
meteor run --settings settings/dev.json    # With settings
meteor run --extra-packages bundle-visualizer --production  # Temp package
meteor run --verbose                       # Print all build output
meteor run --no-lint                       # Skip linters on rebuild
meteor run --no-release-check              # Skip release update check
meteor run --raw-logs                      # Run without parsing logs
meteor run --exclude-archs web.browser.legacy,web.cordova  # Skip architectures
meteor run --allow-incompatible-update     # Allow incompatible package versions
meteor run --mobile-server <url>           # Mobile build server URL
meteor run --cordova-server-port <port>    # Cordova content port

# Debug
meteor run --inspect                       # Enable server-side debugging
meteor run --inspect-brk                   # Debug + pause at startup
SERVER_NODE_OPTIONS=--inspect meteor run
SERVER_NODE_OPTIONS=--inspect-brk meteor run
SERVER_NODE_OPTIONS='--max-old-space-size=4096 --inspect' meteor run

# Migration helper
WARN_WHEN_USING_OLD_API=true meteor run
```

## `meteor generate`

Scaffold code in existing project:

```bash
meteor generate <name>                     # Interactive wizard
meteor generate customer                   # JS by default
meteor generate customer --path=server/admin  # Custom path
meteor generate customer --templatePath=/scaffolds-ts  # Custom templates
meteor generate customer --replaceFn=/fn/replace.js    # Custom replace fn
```

Template variables: `$$name$$`, `$$PascalName$$`, `$$camelName$$`.

Generates in `imports/api/<name>/`:

- `collection.js` / `collection.ts`
- `methods.js` / `methods.ts`
- `publications.js` / `publications.ts`
- `index.js` / `index.ts`

Auto-detects TypeScript if `tsconfig.json` exists.

> **Prefer `meteor generate` over custom scaffold scripts** for basic CRUD modules. It produces idiomatic Meteor 3 async code (exported async functions + `Meteor.methods` wrapper). Use the skill's `scaffold-*.sh` scripts only when you need features `meteor generate` doesn't provide: `--with-schema`, `--with-tests`, React/Blaze components, migrations, or settings files.

## `meteor profile`

Profile build and bundle performance (Meteor 3.2+):

```bash
meteor profile                             # Monitor build + bundle
meteor profile --size                      # Monitor bundle runtime + size
meteor profile --size-only                 # Monitor bundle size only
meteor profile --build                     # Monitor build time
METEOR_IDLE_TIMEOUT=120 meteor profile     # Custom timeout (default 90s)
```

## `meteor debug`

Run with server suspended for debugging (deprecated — prefer `--inspect`):

```bash
meteor debug [--debug-port <port>]         # Default port 5858
```

## `meteor build`

```bash
meteor build <output-dir>
meteor build <output-dir> --architecture os.linux.x86_64
meteor build <output-dir> --server=https://myapp.com:443
meteor build <output-dir> --directory       # Directory instead of tarball
meteor build <output-dir> --debug           # Debuggable
meteor build <output-dir> --mobile-settings settings.json
meteor build <output-dir> --platforms=android,ios
meteor build <output-dir> --server-only     # Skip mobile
```

## `meteor deploy`

```bash
meteor deploy <site>
meteor deploy <site> --settings settings/prod.json
meteor deploy <site> --debug
meteor deploy <site> --free                 # Free tier
meteor deploy <site> --mongo                # Galaxy shared MongoDB
meteor deploy <site> --plan professional    # professional, essentials, or free
meteor deploy <site> --plan professional --container-size standard
meteor deploy <site> --cache-build          # Keep bundle for redeploy
meteor deploy <site> --delete               # Delete app
meteor deploy <site> --owner <org>
meteor deploy <site> --deploy-polling-timeout <ms>  # Wait time (default 15 min)
meteor deploy <site> --no-wait              # Exit after upload, don't wait for deploy
```

## Package Management

```bash
meteor add <package>
meteor add <package>@1.2.3                  # Version constraint
meteor add <package>@=1.2.3                 # Exact version
meteor add 'package@=1.0.0 || =2.0.1'       # OR constraints
meteor remove <package>
meteor list
meteor list --tree                          # Dependency tree
meteor list --json                          # JSON output
meteor update
meteor update --packages-only
meteor update <package>
meteor update --release 3.5
meteor update --patch
meteor search <regex>
meteor show <package>
meteor show METEOR                          # Recommended releases
meteor show --show-all METEOR               # All releases
```

## Platforms (Mobile)

```bash
meteor add-platform ios
meteor add-platform android
meteor remove-platform <platform>
meteor list-platforms
meteor run ios
meteor run ios-device
meteor run android
meteor run android-device
meteor run android --mobile-server 10.0.2.2:3000
meteor ensure-cordova-dependencies
```

## Testing

```bash
meteor test --driver-package meteortesting:mocha
meteor test --full-app --driver-package meteortesting:mocha
meteor test --once --driver-package meteortesting:mocha
meteor test --driver-package meteortesting:mocha --port 3100
meteor test --inspect                       # Debug tests
meteor test --inspect-brk                   # Debug tests + pause at startup
meteor test-packages                         # All local packages
meteor test-packages ./packages/<name>       # Specific package
```

## Publishing

```bash
meteor publish --create                      # First publish
meteor publish                               # Update
meteor publish --release=3.0.3               # For Meteor 3
meteor publish --update                      # Update metadata only
meteor publish-for-arch <package@version>    # Different architecture
meteor publish-release <config.json>         # Release
meteor publish-release --create-track        # New track
```

## Other

```bash
meteor help
meteor help <command>
meteor mongo                                 # Mongo shell (dev DB)
meteor reset                                 # Reset dev DB (DESTRUCTIVE)
meteor lint                                  # Run all linters
meteor shell                                 # Interactive server shell
meteor npm <command>                         # Bundled npm
meteor node <command>                        # Bundled node
meteor login                                 # Log in to Meteor developer account
meteor login --email                         # Log in by email address
meteor logout                                # Log out
meteor whoami                                # Show logged-in username
meteor admin                                 # Administrative commands
```

### `METEOR_SESSION_FILE`

Set before `meteor login` to generate a session token file for CI/CD:

```bash
METEOR_SESSION_FILE=token.json meteor login
```

## `meteor shell`

Connects to running server for interactive evaluation:

```bash
meteor shell
> Meteor.isServer
true
> await TasksCollection.find().fetchAsync()
[ { _id: '...', text: '...' } ]
> .reload  # reload with server
```
