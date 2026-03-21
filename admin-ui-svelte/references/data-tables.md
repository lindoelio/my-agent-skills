# Data Tables Reference

Admin data tables with pagination, sorting, and filtering using Skeleton.

## Basic Table

```svelte
<script lang="ts">
  interface User {
    id: number;
    name: string;
    email: string;
    role: string;
    status: 'active' | 'inactive';
    createdAt: string;
  }
  
  let users: User[] = $state([
    { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin', status: 'active', createdAt: '2024-01-15' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User', status: 'active', createdAt: '2024-01-16' },
    { id: 3, name: 'Bob Wilson', email: 'bob@example.com', role: 'Editor', status: 'inactive', createdAt: '2024-01-17' },
  ]);
</script>

<div class="overflow-x-auto rounded-xl border border-surface-200-800">
  <table class="w-full text-sm">
    <thead class="bg-surface-100-900">
      <tr>
        <th class="p-4 text-left text-surface-950-50 font-medium">Name</th>
        <th class="p-4 text-left text-surface-950-50 font-medium">Email</th>
        <th class="p-4 text-left text-surface-950-50 font-medium">Role</th>
        <th class="p-4 text-left text-surface-950-50 font-medium">Status</th>
        <th class="p-4 text-left text-surface-950-50 font-medium">Actions</th>
      </tr>
    </thead>
    <tbody>
      {#each users as user}
        <tr class="border-t border-surface-200-800 hover:bg-surface-100-900 transition-colors">
          <td class="p-4 text-surface-950-50">{user.name}</td>
          <td class="p-4 text-surface-500">{user.email}</td>
          <td class="p-4">
            <span class="badge variant-filled-secondary">{user.role}</span>
          </td>
          <td class="p-4">
            <span class="badge variant-filled-{user.status === 'active' ? 'success' : 'warning'}">
              {user.status}
            </span>
          </td>
          <td class="p-4">
            <div class="flex gap-2">
              <button class="btn btn-sm variant-ghost">Edit</button>
              <button class="btn btn-sm variant-ghost text-error-500">Delete</button>
            </div>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
</div>
```

## Sortable Table

```svelte
<script lang="ts">
  type SortKey = 'name' | 'email' | 'role' | 'createdAt';
  type SortDirection = 'asc' | 'desc';
  
  let users = $state([...]);
  let sortKey = $state<SortKey>('name');
  let sortDirection = $state<SortDirection>('asc');
  
  function handleSort(key: SortKey) {
    if (sortKey === key) {
      sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      sortKey = key;
      sortDirection = 'asc';
    }
  }
  
  let sortedUsers = $derived(
    [...users].sort((a, b) => {
      const aVal = a[sortKey];
      const bVal = b[sortKey];
      const modifier = sortDirection === 'asc' ? 1 : -1;
      
      if (aVal < bVal) return -1 * modifier;
      if (aVal > bVal) return 1 * modifier;
      return 0;
    })
  );
</script>

<table class="w-full">
  <thead>
    <tr>
      <th class="p-4 text-left">
        <button 
          onclick={() => handleSort('name')}
          class="flex items-center gap-2 text-surface-950-50 font-medium hover:text-primary-500"
        >
          Name
          {#if sortKey === 'name'}
            <svg class="w-4 h-4 {sortDirection === 'desc' ? 'rotate-180' : ''}" viewBox="0 0 24 24">
              <path d="M7 10l5 5 5-5H7z" fill="currentColor"/>
            </svg>
          {/if}
        </button>
      </th>
      <!-- More sortable headers... -->
    </tr>
  </thead>
  <!-- tbody... -->
</table>
```

## Searchable Table

```svelte
<script lang="ts">
  let users = $state([...]);
  let searchQuery = $state('');
  
  let filteredUsers = $derived(
    users.filter(user => 
      user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.email.toLowerCase().includes(searchQuery.toLowerCase())
    )
  );
</script>

<div class="space-y-4">
  <div class="relative">
    <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-surface-500" viewBox="0 0 24 24">
      <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" fill="none" stroke="currentColor" stroke-width="2"/>
    </svg>
    <input 
      type="search"
      bind:value={searchQuery}
      placeholder="Search users..."
      class="input variant-form pl-10 w-full"
    />
  </div>
  
  <table class="w-full">
    <!-- table content with {#each filteredUsers as user} -->
  </table>
</div>
```

## Pagination

```svelte
<script lang="ts">
  let users = $state([...]);
  let currentPage = $state(1);
  let itemsPerPage = $state(10);
  
  let totalPages = $derived(Math.ceil(users.length / itemsPerPage));
  let startIndex = $derived((currentPage - 1) * itemsPerPage);
  let endIndex = $derived(startIndex + itemsPerPage);
  let paginatedUsers = $derived(users.slice(startIndex, endIndex));
  
  function goToPage(page: number) {
    currentPage = Math.max(1, Math.min(page, totalPages));
  }
  
  let pages = $derived(
    Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
      const startPage = Math.max(1, Math.min(currentPage - 2, totalPages - 4));
      return startPage + i;
    })
  );
</script>

<div class="space-y-4">
  <table class="w-full">
    <!-- tbody with {#each paginatedUsers as user} -->
  </table>
  
  <div class="flex items-center justify-between">
    <p class="text-sm text-surface-500">
      Showing {startIndex + 1} to {Math.min(endIndex, users.length)} of {users.length} results
    </p>
    
    <div class="flex items-center gap-1">
      <button 
        class="btn btn-sm variant-ghost"
        onclick={() => goToPage(currentPage - 1)}
        disabled={currentPage === 1}
      >
        Previous
      </button>
      
      {#each pages as page}
        <button 
          class="btn btn-sm {currentPage === page ? 'variant-filled-primary' : 'variant-ghost'}"
          onclick={() => goToPage(page)}
        >
          {page}
        </button>
      {/each}
      
      <button 
        class="btn btn-sm variant-ghost"
        onclick={() => goToPage(currentPage + 1)}
        disabled={currentPage === totalPages}
      >
        Next
      </button>
    </div>
  </div>
</div>
```

## Bulk Actions

```svelte
<script lang="ts">
  let users = $state([...]);
  let selectedIds = $state<Set<number>>(new Set());
  
  function toggleAll() {
    if (selectedIds.size === users.length) {
      selectedIds = new Set();
    } else {
      selectedIds = new Set(users.map(u => u.id));
    }
  }
  
  function toggleOne(id: number) {
    const newSet = new Set(selectedIds);
    if (newSet.has(id)) {
      newSet.delete(id);
    } else {
      newSet.add(id);
    }
    selectedIds = newSet;
  }
  
  async function bulkDelete() {
    if (confirm(`Delete ${selectedIds.size} items?`)) {
      users = users.filter(u => !selectedIds.has(u.id));
      selectedIds = new Set();
    }
  }
</script>

{#if selectedIds.size > 0}
  <div class="bg-primary-500 text-white p-4 rounded-lg mb-4 flex items-center justify-between">
    <span>{selectedIds.size} items selected</span>
    <div class="flex gap-2">
      <button class="btn btn-sm variant-filled" onclick={bulkDelete}>
        Delete Selected
      </button>
      <button class="btn btn-sm variant-ghost" onclick={() => selectedIds = new Set()}>
        Clear Selection
      </button>
    </div>
  </div>
{/if}

<table class="w-full">
  <thead>
    <tr>
      <th class="p-4 w-12">
        <input 
          type="checkbox"
          checked={selectedIds.size === users.length}
          onchange={toggleAll}
          class="w-4 h-4"
        />
      </th>
      <th class="p-4 text-left">Name</th>
      <!-- more headers -->
    </tr>
  </thead>
  <tbody>
    {#each users as user}
      <tr class="border-t border-surface-200-800 hover:bg-surface-100-900">
        <td class="p-4">
          <input 
            type="checkbox"
            checked={selectedIds.has(user.id)}
            onchange={() => toggleOne(user.id)}
            class="w-4 h-4"
          />
        </td>
        <td class="p-4">{user.name}</td>
        <!-- more cells -->
      </tr>
    {/each}
  </tbody>
</table>
```

## Empty State

```svelte
{#if users.length === 0}
  <div class="text-center py-12">
    <svg class="w-16 h-16 mx-auto text-surface-500 mb-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">
      <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
    </svg>
    <h3 class="text-lg font-medium text-surface-950-50">No users found</h3>
    <p class="text-surface-500 mt-1">Get started by creating a new user.</p>
    <button class="btn variant-filled-primary mt-4">Add User</button>
  </div>
{:else}
  <!-- Table -->
{/if}
```

## Loading State

```svelte
<script lang="ts">
  let loading = $state(true);
  let users = $state([]);
  
  onMount(async () => {
    users = await fetchUsers();
    loading = false;
  });
</script>

{#if loading}
  <div class="space-y-4">
    {#each Array(5) as _}
      <div class="animate-pulse flex gap-4 p-4">
        <div class="w-12 h-12 bg-surface-200-800 rounded-full"></div>
        <div class="flex-1 space-y-2">
          <div class="h-4 bg-surface-200-800 rounded w-3/4"></div>
          <div class="h-3 bg-surface-200-800 rounded w-1/2"></div>
        </div>
      </div>
    {/each}
  </div>
{:else}
  <!-- Table -->
{/if}
```

## Complete Table Component

```svelte
<script lang="ts" generics="T extends { id: number }">
  interface Column {
    key: string;
    label: string;
    sortable?: boolean;
    render?: (item: T) => string;
  }
  
  interface Props {
    data: T[];
    columns: Column[];
    pageSize?: number;
    searchable?: boolean;
    searchPlaceholder?: string;
  }
  
  let { 
    data, 
    columns, 
    pageSize = 10, 
    searchable = false,
    searchPlaceholder = 'Search...'
  }: Props = $props();
  
  let searchQuery = $state('');
  let sortKey = $state<string | null>(null);
  let sortDirection = $state<'asc' | 'desc'>('asc');
  let currentPage = $state(1);
  let selectedIds = $state<Set<number>>(new Set());
  
  let filteredData = $derived(
    searchable && searchQuery
      ? data.filter(item => 
          columns.some(col => 
            String(item[col.key as keyof T]).toLowerCase().includes(searchQuery.toLowerCase())
          )
        )
      : data
  );
  
  let sortedData = $derived(
    sortKey
      ? [...filteredData].sort((a, b) => {
          const aVal = a[sortKey as keyof T];
          const bVal = b[sortKey as keyof T];
          const modifier = sortDirection === 'asc' ? 1 : -1;
          return aVal < bVal ? -1 * modifier : aVal > bVal ? 1 * modifier : 0;
        })
      : filteredData
  );
  
  let totalPages = $derived(Math.ceil(sortedData.length / pageSize));
  let paginatedData = $derived(
    sortedData.slice((currentPage - 1) * pageSize, currentPage * pageSize)
  );
</script>

<div class="space-y-4">
  {#if searchable}
    <input 
      type="search"
      bind:value={searchQuery}
      placeholder={searchPlaceholder}
      class="input variant-form"
    />
  {/if}
  
  <div class="overflow-x-auto rounded-xl border border-surface-200-800">
    <table class="w-full text-sm">
      <thead class="bg-surface-100-900">
        <tr>
          <th class="p-4 w-12">
            <input type="checkbox" class="w-4 h-4" />
          </th>
          {#each columns as col}
            <th class="p-4 text-left text-surface-950-50 font-medium">
              {#if col.sortable}
                <button onclick={() => { /* sort logic */ }}>
                  {col.label}
                </button>
              {:else}
                {col.label}
              {/if}
            </th>
          {/each}
        </tr>
      </thead>
      <tbody>
        {#each paginatedData as item}
          <tr class="border-t border-surface-200-800 hover:bg-surface-100-900">
            <td class="p-4">
              <input type="checkbox" class="w-4 h-4" />
            </td>
            {#each columns as col}
              <td class="p-4">
                {col.render ? col.render(item) : item[col.key as keyof T]}
              </td>
            {/each}
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
  
  <div class="flex justify-between items-center text-sm text-surface-500">
    <span>Showing {paginatedData.length} of {data.length}</span>
    <div class="flex gap-1">
      <button class="btn btn-sm variant-ghost" disabled={currentPage === 1}>Prev</button>
      <button class="btn btn-sm variant-ghost" disabled={currentPage === totalPages}>Next</button>
    </div>
  </div>
</div>
```