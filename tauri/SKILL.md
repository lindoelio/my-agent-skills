---
name: tauri
description: Use this skill whenever building, modifying, planning, or debugging Tauri V2 applications. Triggers on requests involving Tauri, desktop apps, cross-platform apps, Rust backends with web frontends, or Tauri mobile (iOS/Android). Provides comprehensive V2 architecture guidance, CLI commands, mobile setup, IPC patterns, and capability/permission management to prevent hallucinations and increase development velocity.
---

# Tauri V2 Developer Skill

Tauri V2 is a framework for building tiny, blazing fast, secure binaries for all major desktop and mobile platforms using web technologies for the frontend and Rust (with Swift/Kotlin on mobile) for the backend.

**CRITICAL:** V2 contains major architectural changes from V1. DO NOT assume V1 APIs or configurations will work.

## Core V2 Architecture Principles

1. **Plugin-First Ecosystem**: Core features (File System, HTTP, Notifications, Dialogs) have been extracted into separate plugins (`@tauri-apps/plugin-*`). You MUST explicitly add the plugin using the CLI (`tauri add <plugin>`) and initialize it in the Rust backend (`tauri::Builder::default().plugin(tauri_plugin_<name>::init())`).
2. **Mobile as First-Class**: iOS and Android are fully supported. Mobile plugins can use native Swift/Kotlin code via Tauri's IPC.
3. **Capabilities & Permissions**: V2 introduces a granular security model. Permissions are scoped strictly via Capabilities. There is no global `allowlist` like in V1.

## Workflow & Initializing

*   **Initialization**: When starting a new project, use `npm create tauri-app@latest` (or the equivalent for pnpm/yarn/cargo). Always select the V2 templates if prompted.
*   **Running**: Use `npm run tauri dev` (or `cargo tauri dev`) to run the development server.
*   **Migration**: If the user has a V1 project, use the CLI command `tauri migrate` as the first step.

## Navigating the Skill

To avoid hallucination and ensure accurate syntax, read the following reference files based on the task:

*   **Capabilities, Permissions, and IPC**: Read `references/architecture_and_security.md` when defining what the frontend is allowed to do, configuring plugins, or writing Rust IPC (`invoke`).
*   **Mobile Setup & CLI Commands**: Read `references/cli_and_mobile.md` when scaffolding, running, building, or specifically targeting Android or iOS, or if you need the exact CLI syntax.

## General Guidance

*   **Frontend Agnostic**: You can use any frontend (React, Svelte, Vue, plain JS). Keep frontend logic isolated from Tauri-specific logic as much as possible for testability.
*   **IPC (Inter-Process Communication)**: Frontend calls Rust via `invoke('command_name', { payload })`. Rust commands must be annotated with `#[tauri::command]`.
*   **Window Management**: Use the `@tauri-apps/api/window` (or `webviewWindow`) for desktop, but remember mobile is strictly single-window. Avoid window-creation logic if targeting mobile.

When the user asks you to implement a Tauri feature:
1. Determine if it requires a plugin (e.g., reading a file requires `plugin-fs`).
2. Add the plugin via CLI (`npm run tauri add <plugin>`).
3. Configure the capability for it.
4. Add the initialization to `src-tauri/src/lib.rs` (or `main.rs`).
5. Write the frontend implementation using `@tauri-apps/plugin-<name>`.