# Components Reference

Quick reference for Skeleton UI components commonly used in admin dashboards.

## Badges

```svelte
<span class="badge variant-filled">Default</span>
<span class="badge variant-filled-primary">Primary</span>
<span class="badge variant-filled-secondary">Secondary</span>
<span class="badge variant-filled-success">Success</span>
<span class="badge variant-filled-warning">Warning</span>
<span class="badge variant-filled-error">Error</span>

<span class="badge variant-outline-primary">Outline</span>
<span class="badge variant-ghost-primary">Ghost</span>

<span class="badge variant-filled rounded-full">Pill</span>
<span class="badge variant-filled-primary text-xs">Small</span>
```

## Buttons

```svelte
<button class="btn variant-filled">Filled</button>
<button class="btn variant-outline">Outline</button>
<button class="btn variant-ghost">Ghost</button>

<button class="btn variant-filled-primary">Primary</button>
<button class="btn variant-filled-secondary">Secondary</button>
<button class="btn variant-filled-success">Success</button>
<button class="btn variant-filled-warning">Warning</button>
<button class="btn variant-filled-error">Error</button>

<button class="btn btn-lg">Large</button>
<button class="btn btn-sm">Small</button>

<button class="btn btn-icon variant-ghost">
  <svg class="w-5 h-5"><!-- icon --></svg>
</button>

<button class="btn variant-filled" disabled>Disabled</button>

<!-- Button with icon -->
<button class="btn variant-filled-primary">
  <svg class="w-5 h-5"><!-- icon --></svg>
  <span>Submit</span>
</button>

<!-- Button group -->
<div class="btn-group">
  <button class="btn variant-filled">Left</button>
  <button class="btn variant-filled">Center</button>
  <button class="btn variant-filled">Right</button>
</div>
```

## Cards

```svelte
<!-- Basic card -->
<div class="card bg-surface-50-950 border border-surface-200-800 p-6 rounded-xl">
  <h3 class="text-lg font-semibold text-surface-950-50">Card Title</h3>
  <p class="text-surface-500 mt-2">Card description text.</p>
</div>

<!-- Card with header and footer -->
<div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl overflow-hidden">
  <div class="px-6 py-4 border-b border-surface-200-800">
    <h3 class="text-lg font-semibold text-surface-950-50">Card Header</h3>
  </div>
  <div class="p-6">
    <p class="text-surface-500">Card content goes here.</p>
  </div>
  <div class="px-6 py-4 border-t border-surface-200-800 bg-surface-100-900">
    <div class="flex gap-2">
      <button class="btn btn-sm variant-ghost">Cancel</button>
      <button class="btn btn-sm variant-filled-primary">Save</button>
    </div>
  </div>
</div>

<!-- Stat card -->
<div class="card bg-surface-50-950 border border-surface-200-800 p-6 rounded-xl">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-sm text-surface-500">Total Revenue</p>
      <p class="text-2xl font-bold text-surface-950-50 mt-1">$45,231</p>
      <p class="text-sm text-success-500 mt-2">+20.1% from last month</p>
    </div>
    <div class="w-12 h-12 rounded-full bg-primary-500/20 flex items-center justify-center">
      <svg class="w-6 h-6 text-primary-500"><!-- dollar icon --></svg>
    </div>
  </div>
</div>
```

## Dialogs

```svelte
<script>
  import { Dialog } from '@skeletonlabs/skeleton-svelte';
  
  let open = $state(false);
</script>

<button class="btn variant-filled" onclick={() => open = true}>
  Open Dialog
</button>

<Dialog bind:open>
  <div class="bg-surface-50-950 rounded-xl max-w-md w-full mx-4 p-6">
    <div class="flex items-center justify-between mb-4">
      <h2 class="text-xl font-bold text-surface-950-50">Dialog Title</h2>
      <button 
        class="btn btn-icon variant-ghost"
        onclick={() => open = false}
      >
        <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    </div>
    
    <p class="text-surface-500 mb-6">Dialog content goes here.</p>
    
    <div class="flex justify-end gap-2">
      <button class="btn variant-ghost" onclick={() => open = false}>Cancel</button>
      <button class="btn variant-filled-primary">Confirm</button>
    </div>
  </div>
</Dialog>
```

## Toast Notifications

```svelte
<script>
  import { toast } from '@skeletonlabs/skeleton-svelte';
  
  function showSuccess() {
    toast.success({
      title: 'Success!',
      body: 'Your changes have been saved.'
    });
  }
  
  function showError() {
    toast.error({
      title: 'Error',
      body: 'Something went wrong. Please try again.'
    });
  }
  
  function showWarning() {
    toast.warning({
      title: 'Warning',
      body: 'This action cannot be undone.'
    });
  }
  
  function showInfo() {
    toast.info({
      title: 'Info',
      body: 'New updates are available.'
    });
  }
</script>

<div class="flex gap-2">
  <button class="btn variant-filled-success" onclick={showSuccess}>Success</button>
  <button class="btn variant-filled-error" onclick={showError}>Error</button>
  <button class="btn variant-filled-warning" onclick={showWarning}>Warning</button>
  <button class="btn variant-filled" onclick={showInfo}>Info</button>
</div>
```

## Avatars

```svelte
<div class="avatar">
  <img src="/avatar.jpg" alt="User" class="w-10 h-10 rounded-full" />
</div>

<div class="avatar">
  <div class="w-10 h-10 rounded-full bg-primary-500 flex items-center justify-center text-white font-medium">
    JD
  </div>
</div>

<!-- Avatar sizes -->
<div class="avatar">
  <img src="/avatar.jpg" class="w-6 h-6 rounded-full" />
</div>
<div class="avatar">
  <img src="/avatar.jpg" class="w-8 h-8 rounded-full" />
</div>
<div class="avatar">
  <img src="/avatar.jpg" class="w-10 h-10 rounded-full" />
</div>
<div class="avatar">
  <img src="/avatar.jpg" class="w-12 h-12 rounded-full" />
</div>

<!-- Avatar group -->
<div class="flex -space-x-2">
  <div class="avatar ring-2 ring-surface-50-950">
    <img src="/avatar1.jpg" class="w-10 h-10 rounded-full" />
  </div>
  <div class="avatar ring-2 ring-surface-50-950">
    <img src="/avatar2.jpg" class="w-10 h-10 rounded-full" />
  </div>
  <div class="avatar ring-2 ring-surface-50-950">
    <img src="/avatar3.jpg" class="w-10 h-10 rounded-full" />
  </div>
  <div class="avatar ring-2 ring-surface-50-950">
    <div class="w-10 h-10 rounded-full bg-surface-200-800 flex items-center justify-center text-xs font-medium">
      +5
    </div>
  </div>
</div>
```

## Progress

```svelte
<div class="progress h-2 bg-surface-200-800 rounded-full overflow-hidden">
  <div class="h-full bg-primary-500 rounded-full" style="width: 60%"></div>
</div>

<div class="progress h-3 bg-surface-200-800 rounded-full overflow-hidden">
  <div class="h-full bg-success-500 rounded-full" style="width: 80%"></div>
</div>

<!-- Progress with label -->
<div>
  <div class="flex justify-between text-sm mb-1">
    <span class="text-surface-950-50">Progress</span>
    <span class="text-surface-500">60%</span>
  </div>
  <div class="progress h-2 bg-surface-200-800 rounded-full overflow-hidden">
    <div class="h-full bg-primary-500 rounded-full" style="width: 60%"></div>
  </div>
</div>
```

## Spinners

```svelte
<div class="spinner w-6 h-6 border-2 border-primary-500 border-t-transparent rounded-full animate-spin"></div>

<div class="spinner w-8 h-8 border-2 border-surface-200-800 border-t-primary-500 rounded-full animate-spin"></div>

<!-- Button with spinner -->
<button class="btn variant-filled-primary" disabled>
  <div class="spinner w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
  Loading...
</button>
```

## Skeleton Loading

```svelte
<div class="animate-pulse space-y-4">
  <div class="h-4 bg-surface-200-800 rounded w-3/4"></div>
  <div class="h-4 bg-surface-200-800 rounded w-1/2"></div>
  <div class="h-4 bg-surface-200-800 rounded w-5/6"></div>
</div>

<!-- Card skeleton -->
<div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl p-6">
  <div class="animate-pulse flex items-center gap-4">
    <div class="w-12 h-12 rounded-full bg-surface-200-800"></div>
    <div class="flex-1 space-y-2">
      <div class="h-4 bg-surface-200-800 rounded w-3/4"></div>
      <div class="h-3 bg-surface-200-800 rounded w-1/2"></div>
    </div>
  </div>
</div>
```

## Tooltips

```svelte
<div class="relative group">
  <button class="btn variant-ghost btn-icon">
    <svg class="w-5 h-5"><!-- info icon --></svg>
  </button>
  <div class="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-3 py-1.5 bg-surface-950-50 text-surface-50-950 text-sm rounded-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all whitespace-nowrap">
    Tooltip text
    <div class="absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-surface-950-50"></div>
  </div>
</div>
```

## Dividers

```svelte
<hr class="border-t border-surface-200-800 my-4" />

<div class="flex items-center gap-4 my-4">
  <div class="flex-1 border-t border-surface-200-800"></div>
  <span class="text-surface-500 text-sm">or</span>
  <div class="flex-1 border-t border-surface-200-800"></div>
</div>
```

## Empty State

```svelte
<div class="text-center py-12">
  <div class="w-16 h-16 bg-surface-200-800 rounded-full mx-auto mb-4 flex items-center justify-center">
    <svg class="w-8 h-8 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">
      <path d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/>
    </svg>
  </div>
  <h3 class="text-lg font-medium text-surface-950-50">No items found</h3>
  <p class="text-surface-500 mt-1">Get started by creating a new item.</p>
  <button class="btn variant-filled-primary mt-4">
    <svg class="w-5 h-5"><!-- plus icon --></svg>
    Add Item
  </button>
</div>
```

## Accordions

```svelte
<script>
  let openItem = $state<string | null>(null);
  
  const items = [
    { id: '1', title: 'Section 1', content: 'Content for section 1' },
    { id: '2', title: 'Section 2', content: 'Content for section 2' },
    { id: '3', title: 'Section 3', content: 'Content for section 3' },
  ];
</script>

<div class="border border-surface-200-800 rounded-xl divide-y divide-surface-200-800">
  {#each items as item}
    <div>
      <button 
        class="w-full flex items-center justify-between p-4 text-left hover:bg-surface-100-900 transition-colors"
        onclick={() => openItem = openItem === item.id ? null : item.id}
      >
        <span class="font-medium text-surface-950-50">{item.title}</span>
        <svg 
          class="w-5 h-5 text-surface-500 transition-transform {openItem === item.id ? 'rotate-180' : ''}"
          viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
        >
          <path d="M19 9l-7 7-7-7"/>
        </svg>
      </button>
      
      {#if openItem === item.id}
        <div class="px-4 pb-4 text-surface-500">
          {item.content}
        </div>
      {/if}
    </div>
  {/each}
</div>
```

## Lists

```svelte
<!-- Unordered list -->
<ul class="space-y-2">
  <li class="flex items-center gap-2">
    <span class="w-1.5 h-1.5 rounded-full bg-primary-500"></span>
    Item one
  </li>
  <li class="flex items-center gap-2">
    <span class="w-1.5 h-1.5 rounded-full bg-primary-500"></span>
    Item two
  </li>
</ul>

<!-- List with actions -->
<ul class="divide-y divide-surface-200-800 border border-surface-200-800 rounded-xl">
  <li class="flex items-center justify-between p-4 hover:bg-surface-100-900">
    <div>
      <p class="font-medium text-surface-950-50">Item Title</p>
      <p class="text-sm text-surface-500">Description</p>
    </div>
    <button class="btn btn-sm variant-ghost">Action</button>
  </li>
</ul>
```

## Tabs

```svelte
<script>
  import { Tabs } from '@skeletonlabs/skeleton-svelte';
  
  let selected = $state('tab1');
</script>

<div class="border-b border-surface-200-800 mb-6">
  <div class="flex gap-1">
    <button 
      class="px-4 py-3 text-sm font-medium border-b-2 transition-colors
        {selected === 'tab1' ? 'border-primary-500 text-primary-500' : 'border-transparent text-surface-500 hover:text-surface-950-50'}"
      onclick={() => selected = 'tab1'}
    >
      Tab 1
    </button>
    <button 
      class="px-4 py-3 text-sm font-medium border-b-2 transition-colors
        {selected === 'tab2' ? 'border-primary-500 text-primary-500' : 'border-transparent text-surface-500 hover:text-surface-950-50'}"
      onclick={() => selected = 'tab2'}
    >
      Tab 2
    </button>
  </div>
</div>

{#if selected === 'tab1'}
  <p>Content for tab 1</p>
{:else}
  <p>Content for tab 2</p>
{/if}
```

## File Input

```svelte
<label class="block">
  <span class="text-sm font-medium text-surface-950-50 mb-2 block">Upload File</span>
  <input 
    type="file" 
    class="block w-full text-sm text-surface-500
      file:mr-4 file:py-2 file:px-4
      file:rounded-lg file:border-0
      file:text-sm file:font-medium
      file:bg-primary-500 file:text-white
      hover:file:bg-primary-600
      file:cursor-pointer"
  />
</label>
```

## Switch

```svelte
<script>
  let enabled = $state(false);
</script>

<div class="flex items-center justify-between">
  <div>
    <p class="font-medium text-surface-950-50">Enable notifications</p>
    <p class="text-sm text-surface-500">Receive email notifications</p>
  </div>
  <button 
    role="switch"
    aria-checked={enabled}
    class="relative w-11 h-6 rounded-full transition-colors {enabled ? 'bg-primary-500' : 'bg-surface-200-800'}"
    onclick={() => enabled = !enabled}
  >
    <span 
      class="absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform {enabled ? 'translate-x-5' : ''}"
    ></span>
  </button>
</div>
```