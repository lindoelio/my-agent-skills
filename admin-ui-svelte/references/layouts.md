# Layouts Reference

Responsive admin dashboard layouts using Tailwind CSS and Skeleton.

## Basic Admin Layout

Three-column layout with sidebar, header, and main content:

```svelte
<script lang="ts">
  import Sidebar from './Sidebar.svelte';
  import Header from './Header.svelte';
  
  let { children } = $props();
</script>

<div class="min-h-screen bg-surface-50-950">
  <div class="grid grid-cols-[280px_1fr]">
    <Sidebar />
    <div class="grid grid-rows-[auto_1fr] min-h-screen">
      <Header />
      <main class="p-6">
        {@render children()}
      </main>
    </div>
  </div>
</div>
```

## Responsive Sidebar Layout

Sidebar that collapses on mobile:

```svelte
<script lang="ts">
  let sidebarOpen = $state(false);
  let { children } = $props();
</script>

<div class="min-h-screen bg-surface-50-950">
  <!-- Mobile overlay -->
  {#if sidebarOpen}
    <div 
      class="fixed inset-0 bg-black/50 z-40 lg:hidden"
      onclick={() => sidebarOpen = false}
    ></div>
  {/if}
  
  <!-- Sidebar -->
  <aside 
    class="fixed top-0 left-0 z-50 h-full w-64 bg-surface-100-900 border-r border-surface-200-800
           transition-transform duration-300
           {sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
           lg:translate-x-0 lg:static lg:z-0"
  >
    <div class="p-4">
      <h1 class="text-xl font-bold text-surface-950-50">Admin</h1>
    </div>
    <nav class="p-4">
      <a href="/" class="block p-3 rounded-lg hover:bg-surface-200-800">Dashboard</a>
      <a href="/users" class="block p-3 rounded-lg hover:bg-surface-200-800">Users</a>
      <a href="/settings" class="block p-3 rounded-lg hover:bg-surface-200-800">Settings</a>
    </nav>
  </aside>
  
  <!-- Main content -->
  <div class="lg:ml-64">
    <header class="bg-surface-50-950 border-b border-surface-200-800 p-4 sticky top-0 z-30">
      <button 
        class="lg:hidden btn variant-ghost"
        onclick={() => sidebarOpen = true}
      >
        <svg class="w-6 h-6"><!-- Menu icon --></svg>
      </button>
    </header>
    
    <main class="p-6">
      {@render children()}
    </main>
  </div>
</div>
```

## Sticky Header Layout

Header that stays fixed while scrolling:

```svelte
<div class="min-h-screen">
  <header class="sticky top-0 z-40 bg-surface-50-950/95 backdrop-blur border-b border-surface-200-800">
    <div class="container mx-auto px-4 h-16 flex items-center justify-between">
      <h1 class="text-xl font-bold">Admin</h1>
      <div class="flex items-center gap-4">
        <button class="btn variant-ghost btn-icon">
          <svg class="w-5 h-5"><!-- Bell icon --></svg>
        </button>
        <div class="avatar">
          <img src="/avatar.jpg" alt="User" class="w-8 h-8 rounded-full" />
        </div>
      </div>
    </div>
  </header>
  
  <main class="container mx-auto px-4 py-6">
    <!-- Content -->
  </main>
</div>
```

## Dashboard Grid

Responsive grid for dashboard cards:

```svelte
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
  <div class="card bg-surface-50-950 p-6 rounded-xl border border-surface-200-800">
    <div class="flex items-center justify-between">
      <div>
        <p class="text-surface-500 text-sm">Total Users</p>
        <p class="text-2xl font-bold text-surface-950-50">1,234</p>
      </div>
      <div class="w-12 h-12 rounded-full bg-primary-500/20 flex items-center justify-center">
        <svg class="w-6 h-6 text-primary-500"><!-- Users icon --></svg>
      </div>
    </div>
    <p class="text-sm text-success-500 mt-2">+12% from last month</p>
  </div>
  
  <!-- More cards... -->
</div>
```

## Two-Column Layout

Main content with sidebar panel:

```svelte
<div class="grid grid-cols-1 lg:grid-cols-[1fr_320px] gap-6">
  <div class="space-y-6">
    <!-- Main content -->
  </div>
  
  <aside class="space-y-6">
    <!-- Sidebar content -->
  </aside>
</div>
```

## Three-Column Layout

Content flanked by two sidebars:

```svelte
<div class="grid grid-cols-1 lg:grid-cols-[240px_1fr_240px] gap-6">
  <aside class="hidden lg:block">
    <!-- Left sidebar -->
  </aside>
  
  <main>
    <!-- Main content -->
  </main>
  
  <aside class="hidden lg:block">
    <!-- Right sidebar -->
  </aside>
</div>
```

## Full Layout Component

Complete admin layout with all features:

```svelte
<script lang="ts">
  import { page } from '$app/stores';
  
  interface Props {
    title?: string;
    children: import('svelte').Snippet;
  }
  
  let { title = 'Dashboard', children }: Props = $props();
  
  let sidebarOpen = $state(false);
  
  const navItems = [
    { href: '/', label: 'Dashboard', icon: 'dashboard' },
    { href: '/users', label: 'Users', icon: 'users' },
    { href: '/analytics', label: 'Analytics', icon: 'chart' },
    { href: '/reports', label: 'Reports', icon: 'document' },
    { href: '/settings', label: 'Settings', icon: 'settings' },
  ];
</script>

<div class="min-h-screen bg-surface-50-950">
  <!-- Mobile sidebar overlay -->
  {#if sidebarOpen}
    <div 
      class="fixed inset-0 bg-black/50 z-40 lg:hidden"
      onclick={() => sidebarOpen = false}
      aria-hidden="true"
    ></div>
  {/if}
  
  <!-- Sidebar -->
  <aside 
    class="fixed top-0 left-0 z-50 h-full w-64 bg-surface-100-900 border-r border-surface-200-800
           transform transition-transform duration-300 ease-in-out
           {sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
           lg:translate-x-0 lg:static lg:z-0"
  >
    <!-- Logo -->
    <div class="h-16 flex items-center px-6 border-b border-surface-200-800">
      <span class="text-xl font-bold text-surface-950-50">Admin Panel</span>
    </div>
    
    <!-- Navigation -->
    <nav class="p-4" aria-label="Main navigation">
      <ul class="space-y-1">
        {#each navItems as item}
          <li>
            <a 
              href={item.href}
              class="flex items-center gap-3 px-4 py-3 rounded-lg transition-colors
                {$page.url.pathname === item.href 
                  ? 'bg-primary-500 text-white' 
                  : 'text-surface-500 hover:bg-surface-200-800 hover:text-surface-950-50'}"
            >
              <span class="w-5 h-5">{item.icon}</span>
              <span>{item.label}</span>
            </a>
          </li>
        {/each}
      </ul>
    </nav>
  </aside>
  
  <!-- Main area -->
  <div class="lg:ml-64">
    <!-- Header -->
    <header class="sticky top-0 z-30 bg-surface-50-950/95 backdrop-blur border-b border-surface-200-800">
      <div class="h-16 px-4 flex items-center justify-between">
        <!-- Mobile menu button -->
        <button 
          class="lg:hidden btn variant-ghost btn-icon"
          onclick={() => sidebarOpen = true}
          aria-label="Open menu"
        >
          <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M4 6h16M4 12h16M4 18h16"/>
          </svg>
        </button>
        
        <!-- Page title -->
        <h1 class="text-xl font-semibold text-surface-950-50 hidden lg:block">{title}</h1>
        
        <!-- Header actions -->
        <div class="flex items-center gap-4">
          <button class="btn variant-ghost btn-icon" aria-label="Notifications">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
            </svg>
          </button>
          
          <div class="avatar">
            <img src="/avatar.jpg" alt="User avatar" class="w-8 h-8 rounded-full" />
          </div>
        </div>
      </div>
    </header>
    
    <!-- Page content -->
    <main class="p-6">
      {@render children()}
    </main>
  </div>
</div>
```

## Layout Utilities

### Container

```svelte
<div class="container mx-auto px-4 max-w-7xl">
  <!-- Centered content with max width -->
</div>
```

### Scrollable Content

```svelte
<div class="overflow-y-auto h-[calc(100vh-4rem)]">
  <!-- Scrollable area accounting for header height -->
</div>
```

### Min Height

```svelte
<div class="min-h-screen">
  <!-- At least viewport height -->
</div>

<div class="min-h-[calc(100vh-theme(spacing.16))]">
  <!-- Minus header height -->
</div>
```