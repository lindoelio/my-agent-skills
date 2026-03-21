# Templates Reference

Complete admin page templates ready to use.

## Dashboard Page

```svelte
<script lang="ts">
  const stats = [
    { label: 'Total Users', value: '12,345', change: '+12%', icon: 'users', color: 'primary' },
    { label: 'Revenue', value: '$45,231', change: '+8.2%', icon: 'dollar', color: 'success' },
    { label: 'Active Sessions', value: '2,431', change: '+3.1%', icon: 'activity', color: 'warning' },
    { label: 'Conversion Rate', value: '3.24%', change: '-0.5%', icon: 'trending', color: 'error' },
  ];
  
  const recentActivity = [
    { user: 'John Doe', action: 'Created new project', time: '2 min ago' },
    { user: 'Jane Smith', action: 'Updated settings', time: '15 min ago' },
    { user: 'Bob Wilson', action: 'Deleted user account', time: '1 hour ago' },
    { user: 'Alice Brown', action: 'Exported report', time: '2 hours ago' },
  ];
</script>

<div class="space-y-6">
  <!-- Page header -->
  <div>
    <h1 class="text-2xl font-bold text-surface-950-50">Dashboard</h1>
    <p class="text-surface-500 mt-1">Welcome back! Here's what's happening.</p>
  </div>
  
  <!-- Stats grid -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
    {#each stats as stat}
      <div class="card bg-surface-50-950 border border-surface-200-800 p-6 rounded-xl">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-surface-500">{stat.label}</p>
            <p class="text-2xl font-bold text-surface-950-50 mt-1">{stat.value}</p>
          </div>
          <div class="w-12 h-12 rounded-full bg-{stat.color}-500/20 flex items-center justify-center">
            <span class="w-6 h-6 text-{stat.color}-500">{stat.icon}</span>
          </div>
        </div>
        <p class="text-sm mt-3 {stat.change.startsWith('+') ? 'text-success-500' : 'text-error-500'}">
          {stat.change} from last month
        </p>
      </div>
    {/each}
  </div>
  
  <!-- Main content grid -->
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Chart area -->
    <div class="lg:col-span-2 card bg-surface-50-950 border border-surface-200-800 rounded-xl p-6">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-lg font-semibold text-surface-950-50">Overview</h2>
        <select class="select variant-form text-sm">
          <option>Last 7 days</option>
          <option>Last 30 days</option>
          <option>Last 90 days</option>
        </select>
      </div>
      <!-- Add your chart component here -->
      <div class="h-64 flex items-center justify-center text-surface-500">
        Chart placeholder
      </div>
    </div>
    
    <!-- Recent activity -->
    <div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl p-6">
      <h2 class="text-lg font-semibold text-surface-950-50 mb-4">Recent Activity</h2>
      <ul class="space-y-4">
        {#each recentActivity as activity}
          <li class="flex items-start gap-3">
            <div class="w-8 h-8 rounded-full bg-primary-500/20 flex items-center justify-center flex-shrink-0">
              <span class="text-primary-500 text-xs font-medium">
                {activity.user.split(' ').map(n => n[0]).join('')}
              </span>
            </div>
            <div>
              <p class="text-sm text-surface-950-50">{activity.user}</p>
              <p class="text-xs text-surface-500">{activity.action}</p>
              <p class="text-xs text-surface-500 mt-1">{activity.time}</p>
            </div>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</div>
```

## Users List Page

```svelte
<script lang="ts">
  let searchQuery = $state('');
  let selectedRole = $state('all');
  
  const users = [
    { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin', status: 'active', avatar: '/avatar1.jpg' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User', status: 'active', avatar: '/avatar2.jpg' },
    { id: 3, name: 'Bob Wilson', email: 'bob@example.com', role: 'Editor', status: 'inactive', avatar: '/avatar3.jpg' },
    { id: 4, name: 'Alice Brown', email: 'alice@example.com', role: 'User', status: 'active', avatar: '/avatar4.jpg' },
    { id: 5, name: 'Charlie Davis', email: 'charlie@example.com', role: 'User', status: 'pending', avatar: '/avatar5.jpg' },
  ];
  
  let filteredUsers = $derived(
    users.filter(user => {
      const matchesSearch = user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        user.email.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesRole = selectedRole === 'all' || user.role.toLowerCase() === selectedRole;
      return matchesSearch && matchesRole;
    })
  );
</script>

<div class="space-y-6">
  <!-- Page header -->
  <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
    <div>
      <h1 class="text-2xl font-bold text-surface-950-50">Users</h1>
      <p class="text-surface-500 mt-1">Manage your team members and their roles.</p>
    </div>
    <button class="btn variant-filled-primary">
      <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M12 4v16m8-8H4"/>
      </svg>
      Add User
    </button>
  </div>
  
  <!-- Filters -->
  <div class="flex flex-col sm:flex-row gap-4">
    <div class="relative flex-1">
      <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
      </svg>
      <input 
        type="search"
        bind:value={searchQuery}
        placeholder="Search users..."
        class="input variant-form pl-10 w-full"
      />
    </div>
    <select bind:value={selectedRole} class="select variant-form w-full sm:w-40">
      <option value="all">All Roles</option>
      <option value="admin">Admin</option>
      <option value="editor">Editor</option>
      <option value="user">User</option>
    </select>
  </div>
  
  <!-- Users table -->
  <div class="overflow-x-auto rounded-xl border border-surface-200-800">
    <table class="w-full">
      <thead class="bg-surface-100-900">
        <tr>
          <th class="p-4 text-left text-sm font-medium text-surface-950-50">User</th>
          <th class="p-4 text-left text-sm font-medium text-surface-950-50">Role</th>
          <th class="p-4 text-left text-sm font-medium text-surface-950-50">Status</th>
          <th class="p-4 text-left text-sm font-medium text-surface-950-50">Actions</th>
        </tr>
      </thead>
      <tbody>
        {#each filteredUsers as user}
          <tr class="border-t border-surface-200-800 hover:bg-surface-100-900">
            <td class="p-4">
              <div class="flex items-center gap-3">
                <img src={user.avatar} alt={user.name} class="w-10 h-10 rounded-full" />
                <div>
                  <p class="font-medium text-surface-950-50">{user.name}</p>
                  <p class="text-sm text-surface-500">{user.email}</p>
                </div>
              </div>
            </td>
            <td class="p-4">
              <span class="badge variant-filled-secondary">{user.role}</span>
            </td>
            <td class="p-4">
              <span class="badge variant-filled-{user.status === 'active' ? 'success' : user.status === 'pending' ? 'warning' : 'error'}">
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
  
  <!-- Pagination -->
  <div class="flex items-center justify-between">
    <p class="text-sm text-surface-500">Showing {filteredUsers.length} users</p>
    <div class="flex gap-1">
      <button class="btn btn-sm variant-ghost" disabled>Previous</button>
      <button class="btn btn-sm variant-filled-primary">1</button>
      <button class="btn btn-sm variant-ghost">2</button>
      <button class="btn btn-sm variant-ghost">Next</button>
    </div>
  </div>
</div>
```

## Settings Page

```svelte
<script lang="ts">
  let settings = $state({
    notifications: {
      email: true,
      push: false,
      sms: false,
    },
    privacy: {
      profileVisible: true,
      showEmail: false,
    },
    appearance: {
      theme: 'system',
      compactMode: false,
    }
  });
  
  function saveSettings() {
    // Save logic
  }
</script>

<div class="space-y-6">
  <!-- Page header -->
  <div>
    <h1 class="text-2xl font-bold text-surface-950-50">Settings</h1>
    <p class="text-surface-500 mt-1">Manage your account settings and preferences.</p>
  </div>
  
  <!-- Settings sections -->
  <div class="space-y-6">
    <!-- Notifications -->
    <div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl">
      <div class="p-6 border-b border-surface-200-800">
        <h2 class="text-lg font-semibold text-surface-950-50">Notifications</h2>
        <p class="text-sm text-surface-500 mt-1">Choose how you want to be notified.</p>
      </div>
      <div class="p-6 space-y-4">
        <div class="flex items-center justify-between">
          <div>
            <p class="font-medium text-surface-950-50">Email notifications</p>
            <p class="text-sm text-surface-500">Receive updates via email</p>
          </div>
          <button 
            role="switch"
            aria-checked={settings.notifications.email}
            class="relative w-11 h-6 rounded-full transition-colors {settings.notifications.email ? 'bg-primary-500' : 'bg-surface-200-800'}"
            onclick={() => settings.notifications.email = !settings.notifications.email}
          >
            <span class="absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform {settings.notifications.email ? 'translate-x-5' : ''}"></span>
          </button>
        </div>
        
        <div class="flex items-center justify-between">
          <div>
            <p class="font-medium text-surface-950-50">Push notifications</p>
            <p class="text-sm text-surface-500">Receive push notifications in browser</p>
          </div>
          <button 
            role="switch"
            aria-checked={settings.notifications.push}
            class="relative w-11 h-6 rounded-full transition-colors {settings.notifications.push ? 'bg-primary-500' : 'bg-surface-200-800'}"
            onclick={() => settings.notifications.push = !settings.notifications.push}
          >
            <span class="absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform {settings.notifications.push ? 'translate-x-5' : ''}"></span>
          </button>
        </div>
        
        <div class="flex items-center justify-between">
          <div>
            <p class="font-medium text-surface-950-50">SMS notifications</p>
            <p class="text-sm text-surface-500">Receive notifications via SMS</p>
          </div>
          <button 
            role="switch"
            aria-checked={settings.notifications.sms}
            class="relative w-11 h-6 rounded-full transition-colors {settings.notifications.sms ? 'bg-primary-500' : 'bg-surface-200-800'}"
            onclick={() => settings.notifications.sms = !settings.notifications.sms}
          >
            <span class="absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform {settings.notifications.sms ? 'translate-x-5' : ''}"></span>
          </button>
        </div>
      </div>
    </div>
    
    <!-- Appearance -->
    <div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl">
      <div class="p-6 border-b border-surface-200-800">
        <h2 class="text-lg font-semibold text-surface-950-50">Appearance</h2>
        <p class="text-sm text-surface-500 mt-1">Customize the look and feel.</p>
      </div>
      <div class="p-6 space-y-4">
        <div>
          <label class="block text-sm font-medium text-surface-950-50 mb-2">Theme</label>
          <div class="flex gap-3">
            <button 
              class="flex-1 p-4 rounded-lg border-2 text-center {settings.appearance.theme === 'light' ? 'border-primary-500 bg-primary-500/10' : 'border-surface-200-800'}"
              onclick={() => settings.appearance.theme = 'light'}
            >
              <svg class="w-6 h-6 mx-auto mb-2 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
              </svg>
              <span class="text-sm">Light</span>
            </button>
            <button 
              class="flex-1 p-4 rounded-lg border-2 text-center {settings.appearance.theme === 'dark' ? 'border-primary-500 bg-primary-500/10' : 'border-surface-200-800'}"
              onclick={() => settings.appearance.theme = 'dark'}
            >
              <svg class="w-6 h-6 mx-auto mb-2 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
              </svg>
              <span class="text-sm">Dark</span>
            </button>
            <button 
              class="flex-1 p-4 rounded-lg border-2 text-center {settings.appearance.theme === 'system' ? 'border-primary-500 bg-primary-500/10' : 'border-surface-200-800'}"
              onclick={() => settings.appearance.theme = 'system'}
            >
              <svg class="w-6 h-6 mx-auto mb-2 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
              </svg>
              <span class="text-sm">System</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Save button -->
    <div class="flex justify-end gap-3">
      <button class="btn variant-ghost">Cancel</button>
      <button class="btn variant-filled-primary" onclick={saveSettings}>Save Changes</button>
    </div>
  </div>
</div>
```

## User Detail Page

```svelte
<script lang="ts">
  const user = {
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
    role: 'Admin',
    status: 'active',
    avatar: '/avatar.jpg',
    phone: '+1 (555) 123-4567',
    location: 'San Francisco, CA',
    joined: 'January 15, 2024',
    lastActive: '2 hours ago',
    bio: 'Software developer with 5+ years of experience in web development.',
  };
  
  const recentActivity = [
    { action: 'Updated profile settings', time: '2 hours ago' },
    { action: 'Created new project "Dashboard"', time: '1 day ago' },
    { action: 'Added 3 team members', time: '3 days ago' },
    { action: 'Exported analytics report', time: '1 week ago' },
  ];
</script>

<div class="space-y-6">
  <!-- Breadcrumb -->
  <nav aria-label="Breadcrumb">
    <ol class="flex items-center gap-2 text-sm">
      <li><a href="/" class="text-surface-500 hover:text-primary-500">Users</a></li>
      <li class="text-surface-500">/</li>
      <li class="text-surface-950-50 font-medium">{user.name}</li>
    </ol>
  </nav>
  
  <!-- Profile header -->
  <div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl p-6">
    <div class="flex flex-col sm:flex-row sm:items-center gap-6">
      <img src={user.avatar} alt={user.name} class="w-24 h-24 rounded-full" />
      <div class="flex-1">
        <div class="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-4">
          <h1 class="text-2xl font-bold text-surface-950-50">{user.name}</h1>
          <span class="badge variant-filled-{user.status === 'active' ? 'success' : 'error'}">
            {user.status}
          </span>
        </div>
        <p class="text-surface-500 mt-1">{user.email}</p>
        <div class="flex flex-wrap gap-4 mt-4 text-sm text-surface-500">
          <span class="flex items-center gap-1">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
            </svg>
            {user.role}
          </span>
          <span class="flex items-center gap-1">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
              <path d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
            {user.location}
          </span>
          <span class="flex items-center gap-1">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
            </svg>
            Joined {user.joined}
          </span>
        </div>
      </div>
      <div class="flex gap-2">
        <button class="btn variant-outline">Message</button>
        <button class="btn variant-filled-primary">Edit Profile</button>
      </div>
    </div>
  </div>
  
  <!-- Content grid -->
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- About -->
    <div class="lg:col-span-2 space-y-6">
      <div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl p-6">
        <h2 class="text-lg font-semibold text-surface-950-50 mb-4">About</h2>
        <p class="text-surface-500">{user.bio}</p>
      </div>
      
      <div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl p-6">
        <h2 class="text-lg font-semibold text-surface-950-50 mb-4">Contact Information</h2>
        <dl class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <dt class="text-sm text-surface-500">Email</dt>
            <dd class="text-surface-950-50 mt-1">{user.email}</dd>
          </div>
          <div>
            <dt class="text-sm text-surface-500">Phone</dt>
            <dd class="text-surface-950-50 mt-1">{user.phone}</dd>
          </div>
          <div>
            <dt class="text-sm text-surface-500">Location</dt>
            <dd class="text-surface-950-50 mt-1">{user.location}</dd>
          </div>
          <div>
            <dt class="text-sm text-surface-500">Last Active</dt>
            <dd class="text-surface-950-50 mt-1">{user.lastActive}</dd>
          </div>
        </dl>
      </div>
    </div>
    
    <!-- Activity -->
    <div class="card bg-surface-50-950 border border-surface-200-800 rounded-xl p-6">
      <h2 class="text-lg font-semibold text-surface-950-50 mb-4">Recent Activity</h2>
      <ul class="space-y-4">
        {#each recentActivity as activity}
          <li class="flex gap-3">
            <div class="w-2 h-2 rounded-full bg-primary-500 mt-2"></div>
            <div>
              <p class="text-sm text-surface-950-50">{activity.action}</p>
              <p class="text-xs text-surface-500">{activity.time}</p>
            </div>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</div>
```

## 404 Not Found Page

```svelte
<div class="min-h-[60vh] flex items-center justify-center">
  <div class="text-center">
    <p class="text-6xl font-bold text-surface-200-800">404</p>
    <h1 class="text-2xl font-bold text-surface-950-50 mt-4">Page not found</h1>
    <p class="text-surface-500 mt-2">Sorry, we couldn't find the page you're looking for.</p>
    <a href="/" class="btn variant-filled-primary mt-6">
      Go back home
    </a>
  </div>
</div>
```

## Error Page

```svelte
<script lang="ts">
  interface Props {
    error?: Error;
    message?: string;
  }
  
  let { error, message = 'Something went wrong' }: Props = $props();
</script>

<div class="min-h-[60vh] flex items-center justify-center">
  <div class="text-center max-w-md">
    <div class="w-16 h-16 bg-error-500/20 rounded-full mx-auto mb-6 flex items-center justify-center">
      <svg class="w-8 h-8 text-error-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
      </svg>
    </div>
    <h1 class="text-2xl font-bold text-surface-950-50">Oops!</h1>
    <p class="text-surface-500 mt-2">{message}</p>
    {#if error}
      <pre class="mt-4 p-4 bg-surface-100-900 rounded-lg text-xs text-left overflow-auto text-surface-500">{error.message}</pre>
    {/if}
    <div class="flex gap-2 justify-center mt-6">
      <button class="btn variant-ghost" onclick={() => window.location.reload()}>
        Try again
      </button>
      <a href="/" class="btn variant-filled-primary">Go home</a>
    </div>
  </div>
</div>
```