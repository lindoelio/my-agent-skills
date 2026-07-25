# Tauri V2 CLI & Mobile Target Reference

Tauri CLI commands are run via the project's package manager. For example: `npm run tauri <command>`, `yarn tauri`, `pnpm tauri`, or `cargo tauri`.

## Core CLI Commands

*   `dev` - Run the app in development mode with hot-reloading.
    *   *Options*: `--no-watch` (disable file watcher), `-c, --config <CONFIG>` (merge config JSON), `--release` (run in release mode).
*   `build` - Build the app in release mode (creates installers, binaries).
    *   *Options*: `-d, --debug` (build debug binaries), `--no-bundle` (skip installer creation), `-b, --bundles` (specify formats like deb, rpm, appimage).
*   `init` - Initialize a Tauri project in an existing directory.
    *   *Options*: `-A, --app-name`, `-W, --window-title`, `-D, --frontend-dist`.
*   `info` - Show environment, Rust, and Node.js version info (crucial for debugging). Use `--interactive` to apply automatic fixes.
*   `migrate` - Migrate a project from V1 to V2 automatically.
*   `icon [INPUT]` - Generate icons for all platforms from a single PNG or SVG image.

## Mobile Development (iOS / Android)

Tauri V2 introduces first-class mobile targets. To work with mobile, the host must have Android Studio (Android) and Xcode (iOS, macOS host only) installed.

### Android Commands
*   `android init` - Initializes the Android target (creates `src-tauri/gen/android`).
*   `android dev` - Runs the app on an emulator or connected device.
    *   *Options*: `-o, --open` (Open the generated project in Android Studio instead of running in terminal).
*   `android build` - Builds release APKs or AABs.
    *   *Options*: `--apk`, `--aab`, `--split-per-abi` (split packages by architecture).
*   `android run` - Run in production mode.

### iOS Commands (macOS only)
*   `ios init` - Initializes the iOS target (creates `src-tauri/gen/apple`).
*   `ios dev` - Runs the app on a simulator or connected device.
    *   *Options*: `-o, --open` (Open the generated project in Xcode).
*   `ios build` - Builds release IPAs.
    *   *Options*: `--export-method <METHOD>` (e.g., `app-store-connect`, `debugging`), `--build-number <NUM>`.
*   `ios run` - Run in production mode.

## Plugin and Security CLI Tools

*   `add <PLUGIN>` - Adds a plugin to the frontend and backend simultaneously (e.g., `npm run tauri add fs`).
*   `remove <PLUGIN>` - Removes a plugin.
*   `plugin new <NAME>` - Scaffolds a new standalone plugin project. Supports `--mobile` flag to initialize iOS/Android native codebase.
*   `capability new` - Creates a new capabilities configuration file in `src-tauri/capabilities/`.
*   `permission add` - Adds a permission to a capability.
*   `permission ls` - Lists all available permissions.
*   `signer` - Commands to manage updates. `signer generate` creates new signing keys, `signer sign` signs a file for the updater.