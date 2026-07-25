# Modern Build Stack (Meteor 3.3+)

Meteor 3.3+ ships a modern build stack with two major overhauls: Meteor Bundler Optimizations (SWC) and Rspack Bundler Integration.

## Quick Start

New Meteor 3.4+ apps enable the modern build stack by default. For existing apps:

### Meteor Bundler Optimizations (3.3+)

Add to `package.json`:

```json
{
  "meteor": {
    "modern": true
  }
}
```

This enables SWC transpilation, faster builds, and bundler optimizations.

### Rspack Bundler Integration (3.4+)

```bash
meteor add rspack
```

On first run, the package installs the required Rspack setup. Rspack bundles your app code while Meteor Bundler produces the final output, maintaining support for Atmosphere packages.

## Requirements for Rspack

### Entry Points

Your app must define entry points in `package.json`:

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

### No Nested Imports

Rspack does not support Meteor's nested imports (imports inside conditions/functions). Migrate them to top-level imports, `require()`, or dynamic `import()`.

```js
// Before (nested import — not supported)
if (condition) {
  import { a as b } from './c';
}

// After (top-level import)
import { a as b } from './c';
if (condition) {
  console.log(b);
}
```

### Reserved Folders

Meteor-Rspack reserves `_build/`, `{public,private}/build-assets/`, and `{public,private}/build-chunks/`. These are auto-generated and added to `.gitignore`.

### Build Plugins

Meteor build plugins (Less, SCSS, CoffeeScript, Svelte) are largely replaced by Rspack alternatives. See the migration topics below.

## Custom `rspack.config.js`

Automatically created when installing the `rspack` package. Use `defineConfig` from `@meteorjs/rspack`:

```js
const { defineConfig } = require('@meteorjs/rspack');
const { rspack } = require('@rspack/core');

module.exports = defineConfig(Meteor => ({
  plugins: [
    Meteor.isClient && new rspack.ProvidePlugin({ _: 'lodash' }),
    Meteor.isServer && new NodePolyfillPlugin(),
    new rspack.ProgressPlugin(),
  ].filter(Boolean),
}));
```

### Available Flags

| Flag | Type | Description |
|------|------|-------------|
| `isDevelopment` | boolean | Development mode |
| `isProduction` | boolean | Production mode |
| `isClient` | boolean | Client build |
| `isServer` | boolean | Server build |
| `isTest` | boolean | Test mode |
| `isDebug` | boolean | Debug mode |
| `isRun` | boolean | `meteor run` |
| `isBuild` | boolean | `meteor build` |

### Helper Functions

| Helper | Purpose |
|--------|---------|
| `compileWithRspack(deps)` | Force Rspack to compile specific npm deps |
| `compileWithMeteor(deps)` | Mark deps as externals (native modules, precompiled) |
| `splitVendorChunk()` | Split vendor libraries into separate chunk |
| `extendSwcConfig(opts)` | Smart-merge SWC options (recommended) |
| `replaceSwcConfig(opts)` | Full SWC config replacement |
| `enablePortableBuild()` | Omit `isDevelopment`/`isProduction` from bundle |
| `setCache(mode)` | Enable/disable Rspack cache (`true`, `false`, `'memory'`) |
| `persistDevFiles(opts)` | Control which dev files are written to disk |
| `disablePlugins(names)` | Disable default Rspack plugins |

## Framework Integration

All frameworks are supported out of the box with `meteor create`:

```bash
meteor create myapp --react       # React + Rspack
meteor create myapp --vue         # Vue 3 + Rspack
meteor create myapp --svelte      # Svelte + Rspack
meteor create myapp --solid       # Solid + Rspack
meteor create myapp --tailwind    # React + Tailwind + Rspack
meteor create myapp --typescript  # React + TypeScript + Rspack
meteor create myapp --angular     # Angular + Rspack (experimental)
meteor create myapp --babel       # Babel instead of SWC
```

## CSS, Less, SCSS

CSS is built-in. For Less:

```bash
npm i -D less less-loader
```

```js
module.exports = defineConfig(Meteor => ({
  module: {
    rules: [{
      test: /\.less$/,
      use: [{ loader: 'less-loader' }],
      type: 'css/auto',
    }],
  },
}));
```

For SCSS:

```bash
npm i -D sass-embedded sass-loader
```

```js
module.exports = defineConfig(Meteor => ({
  module: {
    rules: [{
      test: /\.scss$/i,
      use: [{
        loader: 'sass-loader',
        options: { api: 'modern-compiler', implementation: require.resolve('sass-embedded') },
      }],
      type: 'css/auto',
    }],
  },
}));
```

## CSS Modules

Files named `*.module.css` are automatically scoped locally. Named exports by default:

```js
import { app } from './App.module.css';
```

For default imports, disable `namedExports`:

```js
module.exports = defineConfig(Meteor => ({
  module: {
    parser: {
      'css/auto': { namedExports: false },
      'css/module': { namedExports: false },
    },
  },
}));
```

## Service Worker / PWA (3.4.1+)

Use Workbox with `workbox-webpack-plugin`:

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

## Portable Builds

By default, `Meteor.isDevelopment`/`Meteor.isProduction` are replaced at build time. For a single build across environments:

```js
module.exports = defineConfig(Meteor => ({
  ...Meteor.enablePortableBuild(),
}));
```

## Import Aliases

```js
module.exports = defineConfig(Meteor => ({
  resolve: {
    alias: {
      '@ui': '/imports/ui',
      '@api': '/imports/api',
    },
  },
}));
```

For TypeScript, also update `tsconfig.json`:

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@ui/*": ["imports/ui/*"],
      "@api/*": ["imports/api/*"]
    }
  }
}
```

## Verbose Mode

Enable detailed Rspack logs in `package.json`:

```json
{
  "meteor": {
    "modern": {
      "verbose": true
    }
  }
}
```

## Delegating Dependencies

Force Rspack to compile specific npm deps:

```js
module.exports = defineConfig(Meteor => ({
  ...Meteor.compileWithRspack(['grubba-rpc']),
}));
```

Mark deps as externals (native modules, precompiled):

```js
module.exports = defineConfig(Meteor => ({
  ...(Meteor.isServer ? Meteor.compileWithMeteor(['sharp']) : {}),
}));
```
