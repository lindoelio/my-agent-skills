# Tauri V2 Architecture & Security

## Capabilities & Permissions

In Tauri V2, the security model revolves around **Capabilities**. A capability is a set of permissions mapped to specific windows or webviews. The V1 global allowlist has been entirely removed.

1. **Location**: Capabilities are stored as JSON or TOML files inside `src-tauri/capabilities/`.
2. **Creation**: Use `tauri capability new` to generate a new capability file.
3. **Permissions**: Use `tauri permission add` to add permissions to an existing capability.

### Example Capability (`src-tauri/capabilities/default.json`):
```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "description": "Capability for the main window",
  "windows": [
    "main"
  ],
  "permissions": [
    "core:default",
    "fs:default",
    "fs:allow-read-text-file"
  ]
}
```
*Agents must ensure the specific capabilities (like `fs:allow-read-text-file`) are present before attempting to use plugin functions.*

## The Plugin System

Almost all non-core API functions (like File System, HTTP, OS info, Dialogs) have been moved to plugins.

To use a feature like the filesystem:
1. Run `npm run tauri add fs` (This command automatically adds the frontend package `@tauri-apps/plugin-fs` and the backend cargo crate `tauri-plugin-fs`).
2. In `src-tauri/src/lib.rs` or `main.rs`, initialize the plugin:

```rust
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        // Initialize plugins here
        .plugin(tauri_plugin_fs::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```
3. Update the capability with required permissions (e.g., `fs:default` and scope overrides).

## Inter-Process Communication (IPC)

The bridge between Rust and Frontend. In V2, the frontend core API has moved.

**Rust Side:**
```rust
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

// In Builder setup:
tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![greet])
```

**Frontend Side:**
```javascript
// CRITICAL V2 CHANGE: invoke is imported from /core, NOT /tauri
import { invoke } from '@tauri-apps/api/core'; 

async function sayHello() {
    try {
        const response = await invoke('greet', { name: 'World' });
        console.log(response);
    } catch (error) {
        console.error("IPC Error:", error);
    }
}
```