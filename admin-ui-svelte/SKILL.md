---
name: admin-ui-svelte
description: Use this skill when building admin dashboards, control panels, or internal tools with Tailwind CSS v4, Skeleton UI, and Svelte 5. Triggers for layouts with sidebar navigation, data tables with pagination/sorting, forms with validation, authentication pages, and responsive admin interfaces — even if the user doesn't explicitly mention "admin" or "dashboard." Covers Skeleton components, Svelte 5 runes ($state, $derived), and Tailwind v4 patterns.
license: MIT
compatibility: Requires Vite 6+, Svelte 5, Tailwind CSS 4, Skeleton v4
metadata:
  author: community
  version: "1.0"
  theme: cerberus
---

# Admin UI with Tailwind v4 + Skeleton + Svelte 5

Build modern, responsive admin dashboards using Tailwind CSS v4, Skeleton UI components, and Svelte 5 with runes.

## Gotchas

**Svelte 5 Runes:**
- Use `$state()` for reactive variables, not `let count = 0` with reactivity
- Use `$derived()` for computed values, not `$:` reactive statements
- Use `$effect()` for side effects, not `onMount` for most cases
- Props use `$props()` function, not `export let`

**Tailwind v4 Differences:**
- No `tailwind.config.js` needed — configuration via CSS `@theme` directive
- Import: `@import 'tailwindcss'` not `@tailwind base; @tailwind components; @tailwind utilities`
- Use `@tailwindcss/vite` plugin, not `@tailwindcss/postcss`

**Skeleton UI:**
- Set `data-theme="cerberus"` on `<html>` element for theme activation
- Color tokens are dual-mode: `bg-surface-50-950` (light-dark), `text-surface-950-50`
- Import Skeleton CSS after Tailwind: `@import '@skeletonlabs/skeleton'`
- Skeleton v4 uses Zag.js for components — check imports from `@skeletonlabs/skeleton-svelte`

**Common Mistakes:**
- Don't use `class="btn btn-primary"` — Skeleton uses `class="btn variant-filled-primary"`
- Don't forget `data-theme` attribute — components won't render correctly without it
- Don't mix Svelte 4 and 5 syntax in the same file

## Quick Start

### CDN Setup (for prototyping)

```html
<!doctype html>
<html lang="en" data-theme="cerberus">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Admin Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@skeletonlabs/skeleton@latest/themes/cerberus.css" />
  </head>
  <body class="bg-surface-50-950">
    <div class="container mx-auto p-4">
      <h1 class="text-3xl font-bold text-surface-950-50">Dashboard</h1>
    </div>
  </body>
</html>
```

### Full Project Setup

See [installation guide](references/installation.md) for complete Vite + Svelte 5 + Tailwind v4 + Skeleton setup.

## Core Layout Pattern

Admin dashboards typically use a three-region layout: sidebar, header, main content.

```svelte
<script>
  let sidebarOpen = $state(true);
</script>

<div class="grid min-h-screen grid-cols-[auto_1fr]">
  <aside class="bg-surface-100-900 w-64 border-r border-surface-200-800">
    <nav class="p-4">
      <a href="/" class="block p-2 hover:bg-surface-200-800 rounded">Dashboard</a>
      <a href="/users" class="block p-2 hover:bg-surface-200-800 rounded">Users</a>
      <a href="/settings" class="block p-2 hover:bg-surface-200-800 rounded">Settings</a>
    </nav>
  </aside>

  <div class="grid grid-rows-[auto_1fr]">
    <header class="bg-surface-50-950 border-b border-surface-200-800 p-4 sticky top-0 z-10">
      <button onclick={() => sidebarOpen = !sidebarOpen}>Menu</button>
    </header>

    <main class="p-6">
      <slot />
    </main>
  </div>
</div>
```

For responsive layouts with collapsible sidebar, see [layouts reference](references/layouts.md).

## Data Tables

Basic admin table with Skeleton styling:

```svelte
<script>
  import { Table } from '@skeletonlabs/skeleton-svelte';

  let users = $state([
    { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User' },
  ]);
</script>

<div class="overflow-x-auto rounded-lg border border-surface-200-800">
  <table class="w-full">
    <thead class="bg-surface-100-900">
      <tr>
        <th class="p-3 text-left text-surface-950-50">Name</th>
        <th class="p-3 text-left text-surface-950-50">Email</th>
        <th class="p-3 text-left text-surface-950-50">Role</th>
        <th class="p-3 text-left text-surface-950-50">Actions</th>
      </tr>
    </thead>
    <tbody>
      {#each users as user}
        <tr class="border-t border-surface-200-800 hover:bg-surface-100-900">
          <td class="p-3">{user.name}</td>
          <td class="p-3">{user.email}</td>
          <td class="p-3">
            <span class="badge variant-filled">{user.role}</span>
          </td>
          <td class="p-3">
            <button class="btn btn-sm variant-ghost">Edit</button>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
</div>
```

For pagination, sorting, and filtering, see [data-tables reference](references/data-tables.md).

## Forms

### Basic Form Pattern

```svelte
<script>
  let formData = $state({
    email: '',
    password: '',
    remember: false
  });

  async function handleSubmit() {
    // Handle form submission
  }
</script>

<form onsubmit={handleSubmit} class="space-y-4">
  <div>
    <label for="email" class="label">Email</label>
    <input
      type="email"
      id="email"
      bind:value={formData.email}
      class="input variant-form"
      placeholder="you@example.com"
    />
  </div>

  <div>
    <label for="password" class="label">Password</label>
    <input
      type="password"
      id="password"
      bind:value={formData.password}
      class="input variant-form"
    />
  </div>

  <div class="flex items-center gap-2">
    <input type="checkbox" id="remember" bind:checked={formData.remember} />
    <label for="remember" class="label">Remember me</label>
  </div>

  <button type="submit" class="btn variant-filled">Sign In</button>
</form>
```

For validation, file uploads, and advanced form patterns, see [forms reference](references/forms.md).

## Navigation

### Sidebar Navigation

```svelte
<script>
  import { page } from '$app/stores';

  const navItems = [
    { href: '/', label: 'Dashboard', icon: 'dashboard' },
    { href: '/users', label: 'Users', icon: 'users' },
    { href: '/analytics', label: 'Analytics', icon: 'chart' },
    { href: '/settings', label: 'Settings', icon: 'settings' },
  ];
</script>

<nav class="flex flex-col gap-1">
  {#each navItems as item}
    <a
      href={item.href}
      class="flex items-center gap-3 p-3 rounded-lg transition-colors
        {$page.url.pathname === item.href
          ? 'bg-primary-500 text-white'
          : 'hover:bg-surface-200-800'}"
    >
      <span class="w-5 h-5">{item.icon}</span>
      <span>{item.label}</span>
    </a>
  {/each}
</nav>
```

### Breadcrumbs

```svelte
<nav aria-label="Breadcrumb">
  <ol class="flex items-center gap-2 text-sm">
    <li><a href="/" class="hover:text-primary-500">Home</a></li>
    <li class="text-surface-500">/</li>
    <li><a href="/users" class="hover:text-primary-500">Users</a></li>
    <li class="text-surface-500">/</li>
    <li class="text-surface-950-50 font-medium">Edit User</li>
  </ol>
</nav>
```

For complete navigation patterns, see [navigation reference](references/navigation.md).

## Common Components

### Cards

```svelte
<div class="card bg-surface-50-950 border border-surface-200-800 p-4 rounded-xl">
  <h3 class="text-lg font-semibold text-surface-950-50">Card Title</h3>
  <p class="text-surface-500 mt-2">Card description text here.</p>
</div>
```

### Badges

```svelte
<span class="badge variant-filled">Default</span>
<span class="badge variant-filled-primary">Primary</span>
<span class="badge variant-filled-secondary">Secondary</span>
<span class="badge variant-filled-success">Success</span>
<span class="badge variant-filled-warning">Warning</span>
<span class="badge variant-filled-error">Error</span>
```

### Buttons

```svelte
<button class="btn variant-filled">Filled</button>
<button class="btn variant-outline">Outline</button>
<button class="btn variant-ghost">Ghost</button>
<button class="btn variant-filled-primary">Primary</button>
<button class="btn variant-filled-error">Destructive</button>
```

### Dialogs

```svelte
<script>
  import { Dialog } from '@skeletonlabs/skeleton-svelte';

  let open = $state(false);
</script>

<button class="btn" onclick={() => open = true}>Open Dialog</button>

<Dialog bind:open>
  <div class="p-6 bg-surface-50-950 rounded-xl">
    <h2 class="text-xl font-bold">Dialog Title</h2>
    <p class="mt-2 text-surface-500">Dialog content here.</p>
    <div class="flex justify-end gap-2 mt-4">
      <button class="btn variant-ghost" onclick={() => open = false}>Cancel</button>
      <button class="btn variant-filled">Confirm</button>
    </div>
  </div>
</Dialog>
```

For complete component reference, see [components reference](references/components.md).

## Toast Notifications

```svelte
<script>
  import { toast } from '@skeletonlabs/skeleton-svelte';

  function showSuccess() {
    toast.success({ title: 'Success', body: 'Operation completed!' });
  }

  function showError() {
    toast.error({ title: 'Error', body: 'Something went wrong.' });
  }
</script>
```

## Responsive Design

### Breakpoints

| Breakpoint | Min Width | Usage |
|------------|-----------|-------|
| `sm` | 640px | `sm:block` |
| `md` | 768px | `md:grid-cols-2` |
| `lg` | 1024px | `lg:flex` |
| `xl` | 1280px | `xl:w-64` |
| `2xl` | 1536px | `2xl:container` |

### Mobile-First Pattern

```svelte
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
  <div class="card">Card 1</div>
  <div class="card">Card 2</div>
  <div class="card">Card 3</div>
  <div class="card">Card 4</div>
</div>
```

## Accessibility

### Semantic HTML

Always use semantic elements:

```svelte
<header><!-- Logo, navigation --></header>
<aside><!-- Sidebar navigation --></aside>
<main><!-- Primary content --></main>
<nav><!-- Navigation menus --></nav>
<footer><!-- Footer content --></footer>
```

### ARIA Labels

```svelte
<button aria-label="Close menu">
  <svg aria-hidden="true">...</svg>
</button>

<nav aria-label="Main navigation">
  <!-- nav items -->
</nav>
```

### Focus Management

```svelte
<script>
  import { tick } from 'svelte';

  async function openModal() {
    modalOpen = true;
    await tick();
    document.getElementById('first-focusable')?.focus();
  }
</script>
```

## Color Tokens

Skeleton provides semantic color tokens that adapt to dark/light mode:

| Token | Light Mode | Dark Mode |
|-------|------------|-----------|
| `bg-surface-50-950` | Light gray | Near black |
| `bg-surface-100-900` | Lighter | Darker |
| `text-surface-950-50` | Dark text | Light text |
| `border-surface-200-800` | Light border | Dark border |

Use the dual-token pattern for automatic theme adaptation:

```svelte
<div class="bg-surface-50-950 text-surface-950-50 border-surface-200-800">
  Adapts to theme automatically
</div>
```

## Reference Files

Load these files on demand based on the task:

- **[Installation](references/installation.md)** — Read when setting up a new project or encountering build/config errors
- **[Layouts](references/layouts.md)** — Read when building page structure, sidebar layouts, or responsive grids
- **[Data Tables](references/data-tables.md)** — Read when implementing tables with sorting, pagination, or search
- **[Forms](references/forms.md)** — Read when building forms with validation, file uploads, or multi-step flows
- **[Navigation](references/navigation.md)** — Read when implementing sidebar menus, breadcrumbs, or app bars
- **[Auth Pages](references/auth-pages.md)** — Read when building login, register, or password reset pages
- **[Components](references/components.md)** — Read when using Skeleton badges, buttons, cards, dialogs, or toasts
- **[Templates](references/templates.md)** — Read when you need a complete page template (dashboard, users list, settings)