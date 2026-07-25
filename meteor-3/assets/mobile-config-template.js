// mobile-config.js template for Meteor 3.5
// Place this in the project root. NOT included in app bundle.

App.info({
  id: 'com.example.myapp',
  name: 'My App',
  version: '1.0.0',
  author: 'Author Name',
  email: 'contact@example.com',
  website: 'https://example.com',
});

App.setPreference('BackgroundColor', '0xffffffff');
App.setPreference('Orientation', 'portrait');
App.setPreference('android-targetSdkVersion', '33');
App.setPreference('android-minSdkVersion', '28');

App.accessRule('https://*/*');
App.accessRule('http://*/*', { type: 'navigation' });

// Icons (place in public/icons/)
// App.icons({
//   'iphone_2x': 'icons/icon-60@2x.png',
//   'iphone_3x': 'icons/icon-60@3x.png',
//   'android_mdpi': 'icons/android/mdpi.png',
//   'android_hdpi': 'icons/android/hdpi.png',
//   'android_xhdpi': 'icons/android/xhdpi.png',
//   'android_xxhdpi': 'icons/android/xxhdpi.png',
// });

// Splash screens (place in public/splash/)
// App.launchScreens({
//   'ios_universal': 'splash/Default@2x.png',
//   'ios_universal_3x': 'splash/Default@3x.png',
//   'android_universal': 'splash/android_universal.png',
// });

// Android 9+ cleartext for dev HCP (remove in production)
// App.appendToConfig(`
//   <edit-config file="app/src/main/AndroidManifest.xml"
//                mode="merge"
//                target="/manifest/application"
//                xmlns:android="http://schemas.android.com/apk/res/android">
//     <application android:usesCleartextTraffic="true"></application>
//   </edit-config>
// `);