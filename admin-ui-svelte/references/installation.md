# Installation Guide

Complete setup for Vite + Svelte 5 + Tailwind CSS v4 + Skeleton UI.

## Requirements

| Tool | Minimum Version |
|------|-----------------|
| Vite | 6.x |
| Svelte | 5.x |
| Tailwind CSS | 4.x |
| Skeleton | 4.x |

## Quick Setup

### 1. Create Project

```bash
npm create vite@latest my-admin -- --template svelte-ts
cd my-admin
npm install
```

### 2. Install Dependencies

```bash
npm install tailwindcss @tailwindcss/vite
npm install -D @skeletonlabs/skeleton @skeletonlabs/skeleton-svelte
```

### 3. Configure Vite

Update `vite.config.ts`:

```ts
import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [
    tailwindcss(),
    svelte()
  ]
});
```

### 4. Configure CSS

Create or update `src/app.css`:

```css
@import 'tailwindcss';
@import '@skeletonlabs/skeleton';
@import '@skeletonlabs/skeleton-svelte';
@import '@skeletonlabs/skeleton/themes/cerberus';
```

### 5. Set Theme

Update `index.html`:

```html
<!doctype html>
<html lang="en" data-theme="cerberus">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <title>Admin Dashboard</title>
  </head>
  <body class="bg-surface-50-950">
    <div id="app"></div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

### 6. Import CSS

Update `src/main.ts`:

```ts
import './app.css';
import App from './App.svelte';

export default new App({
  target: document.getElementById('app')!
});
```

## Project Structure

```
my-admin/
├── src/
│   ├── lib/
│   │   └── components/
│   │       ├── Layout.svelte
│   │       ├── Sidebar.svelte
│   │       └── Header.svelte
│   ├── routes/
│   │   └── +page.svelte
│   ├── app.css
│   ├── App.svelte
│   └── main.ts
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## SvelteKit Setup (Alternative)

For SvelteKit projects:

```bash
npm create svelte@latest my-admin
cd my-admin
npm install
npm install tailwindcss @tailwindcss/vite
npm install -D @skeletonlabs/skeleton @skeletonlabs/skeleton-svelte
```

### SvelteKit Vite Config

```ts
import adapter from '@sveltejs/adapter-auto';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import tailwindcss from '@tailwindcss/vite';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: vitePreprocess(),
  kit: {
    adapter: adapter(),
  },
  vitePlugin: {
    inspector: true,
  },
};

export default config;
```

Add to `svelte.config.js`:

```js
import tailwindcss from '@tailwindcss/vite';

const config = {
  kit: {
    vite: {
      plugins: [tailwindcss()]
    }
  }
};
```

## Dark Mode Toggle

Add a theme toggle component:

```svelte
<script>
  import { modeCurrent, modeCycle } from '@skeletonlabs/skeleton-svelte';
  
  function toggleTheme() {
    modeCycle();
  }
</script>

<button 
  onclick={toggleTheme}
  class="btn btn-icon variant-ghost"
  aria-label="Toggle theme"
>
  {#if $modeCurrent === 'dark'}
    <svg class="w-5 h-5"><!-- Sun icon --></svg>
  {:else}
    <svg class="w-5 h-5"><!-- Moon icon --></svg>
  {/if}
</button>
```

## Available Themes

| Theme | Description |
|-------|-------------|
| `cerberus` | Clean, modern theme (default) |
| `hamlindigo` | Minimal, professional |
| `terminus` | Dark mode optimized |
| `modern` | Classic blue-based |
| `rocket` | Vibrant purple accent |
| `sahara` | Warm, earthy tones |
| `wintry` | Cool, blue-gray palette |
| `catppuccin` | Pastel colors |

See all themes at: https://www.skeleton.dev/docs/svelte/design/presets

## Verification

Create `src/App.svelte`:

```svelte
<script lang="ts">
  let count = $state(0);
</script>

<main class="min-h-screen bg-surface-50-950 p-8">
  <div class="container mx-auto">
    <h1 class="text-3xl font-bold text-surface-950-50 mb-4">
      Admin Dashboard
    </h1>
    <p class="text-surface-500 mb-6">
      Skeleton UI is configured correctly!
    </p>
    <button 
      class="btn variant-filled-primary"
      onclick={() => count++}
    >
      Count: {count}
    </button>
  </div>
</main>
```

Run the dev server:

```bash
npm run dev
```

## Troubleshooting

### Styles Not Loading

1. Ensure `@import 'tailwindcss'` is first in `app.css`
2. Check that Tailwind plugin comes before Svelte in `vite.config.ts`
3. Verify `data-theme` attribute on `<html>` element

### Component Import Errors

```bash
# Reinstall dependencies
rm -rf node_modules
npm install
```

### TypeScript Errors

Add to `tsconfig.json`:

```json
{
  "compilerOptions": {
    "types": ["svelte", "vite/client"]
  }
}
```

## Additional Resources

- [Tailwind CSS v4 Docs](https://tailwindcss.com/docs)
- [Skeleton Documentation](https://www.skeleton.dev/docs/svelte)
- [Svelte 5 Runes](https://svelte-5-preview.librejs.org/)
- [Vite Documentation](https://vite.dev/guide/)