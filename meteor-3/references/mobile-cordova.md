# Mobile / Cordova

Meteor integrates Apache Cordova for iOS/Android from one codebase.

## Setup

```bash
meteor add-platform ios
meteor add-platform android

# Run on simulator
meteor run ios
meteor run android

# Run on device
meteor run ios-device
meteor run android-device

# With custom mobile server (for HCP on device)
meteor run android --mobile-server 10.0.2.2:3000  # emulator
meteor run android --mobile-server 192.168.1.100:3000  # device (same WiFi)
```

### Prerequisites

**iOS**: Xcode + license + `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

**Android**: Android Studio + JDK + `ANDROID_HOME` + `PATH` (and `gradle` if missing).

**Mac M1**: Zulu JDK 8, ARM Android Studio, `brew install gradle`.

## `mobile-config.js`

Top-level file (NOT included in app bundle):

```js
App.info({
  id: 'com.example.myapp',
  name: 'My App',
  version: '1.0.0',
  author: 'Author',
  email: 'contact@example.com',
  website: 'https://example.com'
});

App.setPreference('BackgroundColor', '0xff0000ff');
App.setPreference('Orientation', 'portrait');
App.setPreference('android-targetSdkVersion', '33');
App.setPreference('android-minSdkVersion', '28');

App.icons({
  'iphone_2x': 'icons/icon-60@2x.png',
  'iphone_3x': 'icons/icon-60@3x.png',
  'android_mdpi': 'icons/android/mdpi.png',
  'android_hdpi': 'icons/android/hdpi.png',
  'android_xhdpi': 'icons/android/xhdpi.png',
  'android_xxhdpi': 'icons/android/xxhdpi.png',
});

App.launchScreens({
  'ios_universal': { src: 'splash/Default@2x.png', srcDarkMode: 'splash/Default@2x~dark.png' },
  'ios_universal_3x': 'splash/Default@3x.png',
  'android_universal': 'splash/android_universal.png',
});

App.accessRule('https://api.example.com/*');
App.accessRule('https://cdn.example.com/*', { type: 'navigation' });

App.appendToConfig(`
  <universal-links>
    <host name="myapp.com" />
  </universal-links>
`);
```

### Android 9+ cleartext (dev HCP)

```js
App.appendToConfig(`
  <edit-config file="app/src/main/AndroidManifest.xml"
               mode="merge"
               target="/manifest/application"
               xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:usesCleartextTraffic="true"></application>
  </edit-config>
`);
```

## Cordova Plugins

```bash
# Exact version required
meteor add cordova:cordova-plugin-camera@5.0.2

# From git
meteor add cordova:cordova-plugin-camera@https://github.com/apache/cordova-plugin-camera.git#5.0.2

# From local path
meteor add cordova:cordova-plugin-camera@file://./plugins/cordova-plugin-camera --link
```

### Use plugins in code

```js
Meteor.startup(() => {
  if (Meteor.isCordova) {
    navigator.camera.getPicture(onSuccess, onFail, { quality: 50 });
  }
});
```

### Configure plugins

```js
App.configurePlugin('cordova-plugin-facebook-connect', {
  APP_ID: '1234567890',
  APP_NAME: 'My App'
});
```

> Re-configuring a plugin may require clearing Cordova build cache: `rm -rf .meteor/local/cordova-build`

## `Meteor.isCordova`

```js
if (Meteor.isCordova) {
  // mobile-only code
  import './mobile-only.js';
}
```

## Local File Access

```js
const url = WebAppLocalServer.localFileSystemUrl('path/to/file');
// http://localhost:<port>/local-filesystem/path/to/file
```

## Hot Code Push (HCP)

Client updates push without app store redeploy.

### Prerequisites

- `--server` matches production `ROOT_URL`
- Same network for local testing

### How it works

1. Server hashes client bundle, publishes hash via DDP
2. Client compares, downloads new bundle in background
3. `Reload._onMigrate` allows/denies reload
4. App reloads with new code

### Control reload

```js
import { Reload } from 'meteor/reload';

Reload._onMigrate((retry) => {
  if (isFormDirty) {
    setTimeout(retry, 5000);
    return [false]; // don't reload yet
  }
  return [true]; // allow reload
});
```

### Compatibility versions

HCP disabled when native versions change. Override:

```bash
METEOR_CORDOVA_COMPAT_VERSION_IOS=1.0.0
METEOR_CORDOVA_COMPAT_VERSION_EXCLUDE='plugin1,plugin2'
```

### `AUTOUPDATE_VERSION`

Must change per deploy for HCP to trigger.

## Build for Stores

```bash
# Build everything
meteor build /path/to/output --server=https://myapp.com:443

# iOS: open Xcode project, archive, submit
open /path/to/output/ios/project/myapp.xcodeproj

# Android: sign and align
jarsigner -keystore my-release-key.keystore \
  /path/to/output/android/project/app-release-unsigned.apk alias_name
zipalign -v 4 \
  /path/to/output/android/project/app-release-unsigned.apk \
  myapp-release.apk
```

### Build options

- `--debug` — debuggable APK
- `--server-only` — skip mobile build
- `--platforms=android` or `--platforms=ios`

## Debugging

- **iOS**: Safari > Develop > [device] (enable Web Inspector in Settings > Safari > Advanced)
- **Android**: Chrome > chrome://inspect > [device]
- `location.reload()` to catch startup errors
- Server logs in terminal

## App Startup Timeout

```js
App.setPreference('WebAppStartupTimeout', '30000'); // 30s (default 20s)
```

If startup fails, rolls back to previous version.
