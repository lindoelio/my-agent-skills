# Packages

Authoring and using packages in Meteor 3. Two ecosystems: **Atmosphere** (Meteor-specific) and **npm** (general JS).

## Using npm Packages

```bash
meteor npm install --save <package>
meteor npm install --save-dev <package>
```

```js
import moment from 'moment';
import { debounce } from 'lodash';
```

### `meteor npm` vs `npm`

`meteor npm` uses the npm bundled with Meteor. Use it for packages with native dependencies (like `bcrypt`) to ensure correct build libraries.

### `meteor-node-stubs`

Included by default. Polyfills Node built-ins for the browser (Buffer, crypto, stream, etc.). Tree-shaken if unused — keep it installed.

### Recompile specific npm packages

```json
{
  "meteor": {
    "nodeModules": {
      "recompile": {
        "very-modern-package": ["client", "server"],
        "somewhat-modern-package": "legacy"
      }
    }
  }
}
```

### Async callbacks from npm packages

In Meteor 3 (no Fibers), wrap callbacks with Promises:

```js
import { promisify } from 'util';

const readFile = promisify(fs.readFile);
const data = await readFile('file.txt', 'utf8');
```

Or use `Meteor.bindEnvironment` for callbacks that need Meteor context:

```js
externalLibrary.doSomething(Meteor.bindEnvironment((result) => {
  // Meteor context (userId, etc.) preserved
  console.log(result);
}));
```

## Using Atmosphere Packages

```bash
meteor add ostrio:flow-router-extra
meteor add jam:method
meteor list
meteor update <package>
meteor remove <package>
```

```js
import { FlowRouter } from 'meteor/ostrio:flow-router-extra';
import { createMethod } from 'meteor/jam:method';
```

## Writing Atmosphere Packages

```bash
meteor create --package username:my-package
```

### `package.js`

```js
Package.describe({
  name: 'username:my-package',
  summary: 'What this does',
  version: '1.0.0',
  git: 'https://github.com/username/meteor-my-package.git',
});

Package.onUse((api) => {
  // Minimum Meteor versions — choose carefully
  // For Meteor 3 packages: use ['1.12.1', '2.3.6', '2.8.1', '3.0']
  api.versionsFrom(['1.12.1', '3.0']);

  api.use('ecmascript');
  api.use('mongo', 'server');

  // Modern: use mainModule instead of addFiles + export
  api.mainModule('my-package.js');
  api.mainModule('server.js', 'server');
  api.mainModule('client.js', 'client');
});

Package.onTest((api) => {
  api.use('username:my-package');
  api.use('meteortesting:mocha');
  api.addFiles('tests.js');
});

Npm.depends({
  'some-npm-pkg': '1.2.3',
});

Cordova.depends({
  'cordova-plugin-camera': '5.0.2',
});
```

### Main module (ES modules)

```js
// my-package.js
export const myFunction = (arg) => arg * 2;
export default { myFunction };
```

Consumers:

```js
import { myFunction } from 'meteor/username:my-package';
import MyPackage from 'meteor/username:my-package';
```

### Peer npm deps

If your package needs React at the app level:

```js
// In package code
import { checkNpmVersions } from 'meteor/tmeasday:check-npm-versions';
checkNpmVersions({ react: '^18.0.0' }, 'username:my-package');
const React = require('react');
```

### Require Meteor 3+

```js
Package.onUse((api) => {
  api.use('isobuild:top-level-await@3.0.0'); // forces Meteor 3+
});
```

### `Meteor.isFibersDisabled`

Branch for Meteor 2 vs 3:

```js
if (Meteor.isFibersDisabled) {
  // Meteor 3.0+ — async APIs
} else {
  // Meteor 2.x — sync APIs
}
```

### Publish

```bash
meteor publish --create  # first time
meteor publish           # updates
meteor publish --release=3.0.3  # publish for Meteor 3 specifically
```

### Local packages

Place in app `packages/` directory, or use `METEOR_PACKAGE_DIRS` env var (colon-separated on Unix).

### Test packages

```bash
meteor test-packages ./ --driver-package meteortesting:mocha
# Headless:
./packages/test-in-console/run.sh "username:my-package"
```

## Writing npm Packages

```bash
mkdir my-package && cd my-package
meteor npm init
```

```js
// index.js
exports.myFunction = (arg) => arg * 2;
```

```bash
# Use locally
meteor npm link ~/my-package
# Add to package.json: "my-package": "1.0.0"
```

For Meteor 3, write as ESM with `"type": "module"` or CJS; target Node 20+.

## Atmosphere vs npm

| Use Atmosphere when | Use npm when |
|---------------------|--------------|
| Depends on Meteor core packages (`ddp`, `mongo`) | General JS reusable beyond Meteor |
| Ships non-JS assets (CSS, fonts) | No Meteor dependency |
| Needs Meteor build system/transpilation | Standard Node package |
| Ships different client/server code | |
| Is a Meteor build plugin | |

> Long-term direction: migrate everything to npm. Atmosphere remains for Meteor-specific build plugins.

## Build Plugins

### Compiler

```js
Package.registerBuildPlugin({
  name: 'compile-pug',
  use: ['caching-compiler@1.0.0'],
  sources: ['plugin/compile-pug.js'],
});

// plugin/compile-pug.js
Plugin.registerCompiler({ extensions: ['pug'] }, () => new PugCompiler());

class PugCompiler {
  processFilesForTarget(files) {
    files.forEach((file) => {
      const output = pug.compile(file.getContentsAsString())();
      file.addJavaScript({
        data: output,
        path: `${file.getPathInPackage()}.js`,
      });
    });
  }
}
```

### Linter

```js
Plugin.registerLinter({ extensions: ['js'] }, () => new MyLinter);

class MyLinter {
  processFilesForPackage(files, options) {
    files.forEach((file) => {
      const lint = lintFile(file.getContentsAsString());
      if (lint) file.error({ message: lint.message, line: lint.line });
    });
  }
}
```

### Minifier

```js
Plugin.registerMinifier({ extensions: ['js'] }, () => new MyMinifier);

class MyMinifier {
  processFilesForBundle(files, options) {
    if (options.minifyMode === 'development') {
      files.forEach((f) => f.addJavaScript({ data: f.getContentsAsBuffer(), path: f.getPathInBundle() }));
      return;
    }
    // Production: minify
  }
}
```

### Isobuild feature packages

| Package | Enables |
|---------|---------|
| `compiler-plugin@1.0.0` | `Plugin.registerCompiler` |
| `linter-plugin@1.0.0` | `Plugin.registerLinter` |
| `minifier-plugin@1.0.0` | `Plugin.registerMinifier` |
| `isobuild:top-level-await@3.0.0` | Forces Meteor 3+ |

### File system on Windows

Use `Plugin.fs` and `Plugin.path` (fiberized sync versions). Use `Plugin.convertToStandardPath` and `Plugin.convertToOSPath` for path conversion.
