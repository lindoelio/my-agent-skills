# Navigation Reference

Navigation components for admin dashboards including sidebar, breadcrumbs, menus, and app bar.

## Sidebar Navigation

### Basic Sidebar

```svelte
<script lang="ts">
  import { page } from '$app/stores';
  
  const navItems = [
    { href: '/', label: 'Dashboard', icon: 'home' },
    { href: '/users', label: 'Users', icon: 'users' },
    { href: '/analytics', label: 'Analytics', icon: 'chart' },
    { href: '/settings', label: 'Settings', icon: 'settings' },
  ];
</script>

<aside class="w-64 bg-surface-100-900 border-r border-surface-200-800 h-screen sticky top-0">
  <div class="p-6">
    <h1 class="text-xl font-bold text-surface-950-50">Admin</h1>
  </div>
  
  <nav class="px-3" aria-label="Main navigation">
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
```

### Collapsible Sidebar with Groups

```svelte
<script lang="ts">
  import { page } from '$app/stores';
  
  const navGroups = [
    {
      title: 'Main',
      items: [
        { href: '/', label: 'Dashboard', icon: 'home' },
        { href: '/analytics', label: 'Analytics', icon: 'chart' },
        { href: '/reports', label: 'Reports', icon: 'document' },
      ]
    },
    {
      title: 'Management',
      items: [
        { href: '/users', label: 'Users', icon: 'users' },
        { href: '/roles', label: 'Roles', icon: 'shield' },
        { href: '/permissions', label: 'Permissions', icon: 'key' },
      ]
    },
    {
      title: 'System',
      items: [
        { href: '/settings', label: 'Settings', icon: 'settings' },
        { href: '/logs', label: 'Logs', icon: 'list' },
      ]
    }
  ];
  
  let collapsedGroups = $state<Set<string>>(new Set());
  
  function toggleGroup(title: string) {
    const newSet = new Set(collapsedGroups);
    if (newSet.has(title)) {
      newSet.delete(title);
    } else {
      newSet.add(title);
    }
    collapsedGroups = newSet;
  }
</script>

<aside class="w-64 bg-surface-100-900 border-r border-surface-200-800 h-screen sticky top-0 overflow-y-auto">
  <div class="p-6">
    <h1 class="text-xl font-bold text-surface-950-50">Admin Panel</h1>
  </div>
  
  <nav class="px-3" aria-label="Main navigation">
    {#each navGroups as group}
      <div class="mb-4">
        <button 
          onclick={() => toggleGroup(group.title)}
          class="flex items-center justify-between w-full px-4 py-2 text-xs font-semibold text-surface-500 uppercase tracking-wider"
        >
          {group.title}
          <svg 
            class="w-4 h-4 transition-transform {collapsedGroups.has(group.title) ? '' : 'rotate-180'}"
            viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
          >
            <path d="M19 9l-7 7-7-7"/>
          </svg>
        </button>
        
        {#if !collapsedGroups.has(group.title)}
          <ul class="space-y-1 mt-1">
            {#each group.items as item}
              <li>
                <a 
                  href={item.href}
                  class="flex items-center gap-3 px-4 py-2.5 rounded-lg transition-colors
                    {$page.url.pathname === item.href 
                      ? 'bg-primary-500 text-white' 
                      : 'text-surface-500 hover:bg-surface-200-800 hover:text-surface-950-50'}"
                >
                  <span class="w-5 h-5">{item.icon}</span>
                  <span class="text-sm">{item.label}</span>
                </a>
              </li>
            {/each}
          </ul>
        {/if}
      </div>
    {/each}
  </nav>
</aside>
```

### Collapsible Sidebar (Mini Mode)

```svelte
<script lang="ts">
  let collapsed = $state(false);
  let expandedItem = $state<string | null>(null);
  
  const navItems = [
    { id: 'dashboard', href: '/', label: 'Dashboard', icon: 'home' },
    { id: 'users', href: '/users', label: 'Users', icon: 'users', children: [
      { href: '/users', label: 'All Users' },
      { href: '/users/roles', label: 'Roles' },
      { href: '/users/permissions', label: 'Permissions' },
    ]},
    { id: 'analytics', href: '/analytics', label: 'Analytics', icon: 'chart' },
    { id: 'settings', href: '/settings', label: 'Settings', icon: 'settings' },
  ];
</script>

<aside 
  class="bg-surface-100-900 border-r border-surface-200-800 h-screen sticky top-0 transition-all duration-300
    {collapsed ? 'w-16' : 'w-64'}"
>
  <!-- Toggle button -->
  <button 
    onclick={() => collapsed = !collapsed}
    class="w-full p-4 border-b border-surface-200-800 flex items-center justify-center"
  >
    <svg class="w-5 h-5 text-surface-500 transition-transform {collapsed ? 'rotate-180' : ''}" viewBox="0 0 24 24">
      <path d="M11 19l-7-7 7-7m8 14l-7-7 7-7" fill="none" stroke="currentColor" stroke-width="2"/>
    </svg>
  </button>
  
  <nav class="p-2">
    <ul class="space-y-1">
      {#each navItems as item}
        <li class="relative">
          {#if item.children}
            <button 
              onclick={() => expandedItem = expandedItem === item.id ? null : item.id}
              class="flex items-center gap-3 w-full px-3 py-2.5 rounded-lg hover:bg-surface-200-800"
            >
              <span class="w-5 h-5 flex-shrink-0">{item.icon}</span>
              {#if !collapsed}
                <span class="flex-1 text-left text-sm">{item.label}</span>
                <svg class="w-4 h-4 {expandedItem === item.id ? 'rotate-180' : ''}" viewBox="0 0 24 24">
                  <path d="M19 9l-7 7-7-7" fill="none" stroke="currentColor" stroke-width="2"/>
                </svg>
              {/if}
            </button>
            
            {#if !collapsed && expandedItem === item.id}
              <ul class="ml-8 mt-1 space-y-1">
                {#each item.children as child}
                  <li>
                    <a href={child.href} class="block px-3 py-2 text-sm text-surface-500 hover:text-surface-950-50 rounded-lg hover:bg-surface-200-800">
                      {child.label}
                    </a>
                  </li>
                {/each}
              </ul>
            {/if}
          {:else}
            <a 
              href={item.href}
              class="flex items-center gap-3 px-3 py-2.5 rounded-lg hover:bg-surface-200-800"
              title={collapsed ? item.label : ''}
            >
              <span class="w-5 h-5 flex-shrink-0">{item.icon}</span>
              {#if !collapsed}
                <span class="text-sm">{item.label}</span>
              {/if}
            </a>
          {/if}
        </li>
      {/each}
    </ul>
  </nav>
</aside>
```

## Breadcrumbs

```svelte
<script lang="ts">
  interface BreadcrumbItem {
    label: string;
    href?: string;
  }
  
  interface Props {
    items: BreadcrumbItem[];
  }
  
  let { items }: Props = $props();
</script>

<nav aria-label="Breadcrumb" class="mb-4">
  <ol class="flex items-center gap-2 text-sm">
    {#each items as item, i}
      <li class="flex items-center gap-2">
        {#if i > 0}
          <svg class="w-4 h-4 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 18l6-6-6-6"/>
          </svg>
        {/if}
        
        {#if item.href}
          <a 
            href={item.href}
            class="text-surface-500 hover:text-primary-500 transition-colors"
          >
            {item.label}
          </a>
        {:else}
          <span class="text-surface-950-50 font-medium">{item.label}</span>
        {/if}
      </li>
    {/each}
  </ol>
</nav>

<!-- Usage -->
<!-- <Breadcrumbs items={[
  { label: 'Home', href: '/' },
  { label: 'Users', href: '/users' },
  { label: 'Edit User' }
]} /> -->
```

## App Bar / Header

```svelte
<script lang="ts">
  import { modeCurrent, modeCycle } from '@skeletonlabs/skeleton-svelte';
  
  let searchOpen = $state(false);
  let searchQuery = $state('');
</script>

<header class="sticky top-0 z-40 bg-surface-50-950/95 backdrop-blur border-b border-surface-200-800">
  <div class="h-16 px-4 flex items-center justify-between gap-4">
    <!-- Left section -->
    <div class="flex items-center gap-4">
      <button class="lg:hidden btn variant-ghost btn-icon" aria-label="Open menu">
        <svg class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M4 6h16M4 12h16M4 18h16"/>
        </svg>
      </button>
      
      <!-- Search -->
      <div class="relative hidden md:block">
        <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
        <input 
          type="search"
          placeholder="Search..."
          class="input variant-form pl-9 w-64 text-sm"
        />
      </div>
    </div>
    
    <!-- Right section -->
    <div class="flex items-center gap-2">
      <!-- Mobile search toggle -->
      <button 
        class="md:hidden btn variant-ghost btn-icon"
        onclick={() => searchOpen = !searchOpen}
        aria-label="Search"
      >
        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
      </button>
      
      <!-- Theme toggle -->
      <button 
        class="btn variant-ghost btn-icon"
        onclick={modeCycle}
        aria-label="Toggle theme"
      >
        {#if $modeCurrent === 'dark'}
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
          </svg>
        {:else}
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
          </svg>
        {/if}
      </button>
      
      <!-- Notifications -->
      <button class="btn variant-ghost btn-icon relative" aria-label="Notifications">
        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
        </svg>
        <span class="absolute top-1 right-1 w-2 h-2 bg-error-500 rounded-full"></span>
      </button>
      
      <!-- User menu -->
      <div class="relative ml-2">
        <button class="flex items-center gap-2">
          <div class="avatar">
            <img src="/avatar.jpg" alt="User" class="w-8 h-8 rounded-full" />
          </div>
          <span class="hidden md:block text-sm font-medium">John Doe</span>
          <svg class="w-4 h-4 text-surface-500 hidden md:block" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M19 9l-7 7-7-7"/>
          </svg>
        </button>
      </div>
    </div>
  </div>
  
  <!-- Mobile search bar -->
  {#if searchOpen}
    <div class="md:hidden px-4 pb-4">
      <input 
        type="search"
        bind:value={searchQuery}
        placeholder="Search..."
        class="input variant-form w-full"
      />
    </div>
  {/if}
</header>
```

## Dropdown Menu

```svelte
<script lang="ts">
  import { Menu } from '@skeletonlabs/skeleton-svelte';
  
  let menuOpen = $state(false);
</script>

<div class="relative">
  <button 
    class="btn variant-ghost"
    onclick={() => menuOpen = !menuOpen}
  >
    Options
    <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M19 9l-7 7-7-7"/>
    </svg>
  </button>
  
  {#if menuOpen}
    <div class="absolute right-0 mt-2 w-48 bg-surface-50-950 border border-surface-200-800 rounded-lg shadow-lg z-50">
      <div class="py-1">
        <a href="#" class="block px-4 py-2 text-sm hover:bg-surface-100-900">Edit</a>
        <a href="#" class="block px-4 py-2 text-sm hover:bg-surface-100-900">Duplicate</a>
        <hr class="my-1 border-surface-200-800" />
        <a href="#" class="block px-4 py-2 text-sm text-error-500 hover:bg-surface-100-900">Delete</a>
      </div>
    </div>
  {/if}
</div>
```

## Tabs Navigation

```svelte
<script lang="ts">
  let activeTab = $state('overview');
  
  const tabs = [
    { id: 'overview', label: 'Overview' },
    { id: 'analytics', label: 'Analytics' },
    { id: 'reports', label: 'Reports' },
    { id: 'settings', label: 'Settings' },
  ];
</script>

<div class="border-b border-surface-200-800">
  <nav class="flex gap-1" aria-label="Tabs">
    {#each tabs as tab}
      <button 
        onclick={() => activeTab = tab.id}
        class="px-4 py-3 text-sm font-medium border-b-2 transition-colors
          {activeTab === tab.id 
            ? 'border-primary-500 text-primary-500' 
            : 'border-transparent text-surface-500 hover:text-surface-950-50 hover:border-surface-300-700'}"
      >
        {tab.label}
      </button>
    {/each}
  </nav>
</div>

<div class="mt-6">
  {#if activeTab === 'overview'}
    <p>Overview content</p>
  {:else if activeTab === 'analytics'}
    <p>Analytics content</p>
  {:else if activeTab === 'reports'}
    <p>Reports content</p>
  {:else if activeTab === 'settings'}
    <p>Settings content</p>
  {/if}
</div>
```

## User Menu

```svelte
<script lang="ts">
  let open = $state(false);
</script>

<div class="relative">
  <button 
    onclick={() => open = !open}
    class="flex items-center gap-3 p-2 rounded-lg hover:bg-surface-200-800 transition-colors"
  >
    <div class="avatar">
      <img src="/avatar.jpg" alt="User" class="w-8 h-8 rounded-full" />
    </div>
    <div class="hidden md:block text-left">
      <p class="text-sm font-medium text-surface-950-50">John Doe</p>
      <p class="text-xs text-surface-500">john@example.com</p>
    </div>
    <svg class="w-4 h-4 text-surface-500 hidden md:block" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M19 9l-7 7-7-7"/>
    </svg>
  </button>
  
  {#if open}
    <div 
      class="absolute right-0 mt-2 w-56 bg-surface-50-950 border border-surface-200-800 rounded-xl shadow-lg z-50"
      onclick:stopPropagation
    >
      <div class="p-4 border-b border-surface-200-800">
        <p class="font-medium text-surface-950-50">John Doe</p>
        <p class="text-sm text-surface-500">john@example.com</p>
      </div>
      
      <div class="py-2">
        <a href="/profile" class="flex items-center gap-3 px-4 py-2 text-sm hover:bg-surface-100-900">
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
          </svg>
          Profile
        </a>
        <a href="/settings" class="flex items-center gap-3 px-4 py-2 text-sm hover:bg-surface-100-900">
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
            <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
          </svg>
          Settings
        </a>
      </div>
      
      <div class="py-2 border-t border-surface-200-800">
        <button class="flex items-center gap-3 w-full px-4 py-2 text-sm text-error-500 hover:bg-surface-100-900">
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
          </svg>
          Sign out
        </button>
      </div>
    </div>
  {/if}
</div>

<svelte:window onclick={() => open = false} />
```

## Page Header

```svelte
<script lang="ts">
  interface Props {
    title: string;
    description?: string;
    breadcrumbs?: { label: string; href?: string }[];
    actions?: import('svelte').Snippet;
  }
  
  let { title, description, breadcrumbs, actions }: Props = $props();
</script>

<div class="mb-6">
  {#if breadcrumbs}
    <nav aria-label="Breadcrumb" class="mb-2">
      <ol class="flex items-center gap-2 text-sm">
        {#each breadcrumbs as item, i}
          <li class="flex items-center gap-2">
            {#if i > 0}
              <span class="text-surface-500">/</span>
            {/if}
            {#if item.href}
              <a href={item.href} class="text-surface-500 hover:text-primary-500">{item.label}</a>
            {:else}
              <span class="text-surface-950-50">{item.label}</span>
            {/if}
          </li>
        {/each}
      </ol>
    </nav>
  {/if}
  
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-2xl font-bold text-surface-950-50">{title}</h1>
      {#if description}
        <p class="mt-1 text-surface-500">{description}</p>
      {/if}
    </div>
    
    {#if actions}
      <div class="flex items-center gap-2">
        {@render actions()}
      </div>
    {/if}
  </div>
</div>
```