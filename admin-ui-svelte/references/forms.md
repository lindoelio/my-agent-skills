# Forms Reference

Admin form patterns with validation, file uploads, and multi-step forms.

## Basic Form

```svelte
<script lang="ts">
  let formData = $state({
    name: '',
    email: '',
    role: 'user',
    bio: ''
  });
  
  async function handleSubmit(e: Event) {
    e.preventDefault();
    // Submit logic
  }
</script>

<form onsubmit={handleSubmit} class="space-y-6 max-w-lg">
  <div>
    <label for="name" class="block text-sm font-medium text-surface-950-50 mb-2">
      Full Name
    </label>
    <input 
      type="text"
      id="name"
      bind:value={formData.name}
      class="input variant-form w-full"
      placeholder="John Doe"
      required
    />
  </div>
  
  <div>
    <label for="email" class="block text-sm font-medium text-surface-950-50 mb-2">
      Email Address
    </label>
    <input 
      type="email"
      id="email"
      bind:value={formData.email}
      class="input variant-form w-full"
      placeholder="john@example.com"
      required
    />
  </div>
  
  <div>
    <label for="role" class="block text-sm font-medium text-surface-950-50 mb-2">
      Role
    </label>
    <select 
      id="role"
      bind:value={formData.role}
      class="select variant-form w-full"
    >
      <option value="user">User</option>
      <option value="editor">Editor</option>
      <option value="admin">Admin</option>
    </select>
  </div>
  
  <div>
    <label for="bio" class="block text-sm font-medium text-surface-950-50 mb-2">
      Bio
    </label>
    <textarea 
      id="bio"
      bind:value={formData.bio}
      class="textarea variant-form w-full"
      rows="4"
      placeholder="Tell us about yourself..."
    ></textarea>
  </div>
  
  <div class="flex gap-3">
    <button type="submit" class="btn variant-filled-primary">Save Changes</button>
    <button type="button" class="btn variant-ghost">Cancel</button>
  </div>
</form>
```

## Form Validation

```svelte
<script lang="ts">
  interface FormData {
    email: string;
    password: string;
    confirmPassword: string;
  }
  
  interface FormErrors {
    email?: string;
    password?: string;
    confirmPassword?: string;
  }
  
  let formData = $state<FormData>({
    email: '',
    password: '',
    confirmPassword: ''
  });
  
  let errors = $state<FormErrors>({});
  let touched = $state<Record<string, boolean>>({});
  
  function validateEmail(email: string): string | undefined {
    if (!email) return 'Email is required';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return 'Invalid email format';
    return undefined;
  }
  
  function validatePassword(password: string): string | undefined {
    if (!password) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return undefined;
  }
  
  function validateField(field: keyof FormData) {
    switch (field) {
      case 'email':
        errors.email = validateEmail(formData.email);
        break;
      case 'password':
        errors.password = validatePassword(formData.password);
        break;
      case 'confirmPassword':
        if (formData.confirmPassword !== formData.password) {
          errors.confirmPassword = 'Passwords do not match';
        } else {
          errors.confirmPassword = undefined;
        }
        break;
    }
  }
  
  function handleBlur(field: keyof FormData) {
    touched[field] = true;
    validateField(field);
  }
  
  let isValid = $derived(
    !errors.email && !errors.password && !errors.confirmPassword &&
    formData.email && formData.password && formData.confirmPassword
  );
  
  async function handleSubmit(e: Event) {
    e.preventDefault();
    
    Object.keys(formData).forEach(key => {
      touched[key] = true;
      validateField(key as keyof FormData);
    });
    
    if (!isValid) return;
    
    // Submit logic
  }
</script>

<form onsubmit={handleSubmit} class="space-y-6 max-w-md">
  <div>
    <label for="email" class="label">Email</label>
    <input 
      type="email"
      id="email"
      class="input variant-form w-full {touched.email && errors.email ? 'input-error' : ''}"
      bind:value={formData.email}
      onblur={() => handleBlur('email')}
    />
    {#if touched.email && errors.email}
      <p class="text-sm text-error-500 mt-1">{errors.email}</p>
    {/if}
  </div>
  
  <div>
    <label for="password" class="label">Password</label>
    <input 
      type="password"
      id="password"
      class="input variant-form w-full {touched.password && errors.password ? 'input-error' : ''}"
      bind:value={formData.password}
      onblur={() => handleBlur('password')}
    />
    {#if touched.password && errors.password}
      <p class="text-sm text-error-500 mt-1">{errors.password}</p>
    {/if}
  </div>
  
  <div>
    <label for="confirmPassword" class="label">Confirm Password</label>
    <input 
      type="password"
      id="confirmPassword"
      class="input variant-form w-full {touched.confirmPassword && errors.confirmPassword ? 'input-error' : ''}"
      bind:value={formData.confirmPassword}
      onblur={() => handleBlur('confirmPassword')}
    />
    {#if touched.confirmPassword && errors.confirmPassword}
      <p class="text-sm text-error-500 mt-1">{errors.confirmPassword}</p>
    {/if}
  </div>
  
  <button 
    type="submit" 
    class="btn variant-filled-primary w-full"
    disabled={!isValid}
  >
    Create Account
  </button>
</form>

<style>
  .input-error {
    border-color: theme('colors.error.500');
  }
  .label {
    @apply block text-sm font-medium text-surface-950-50 mb-2;
  }
</style>
```

## Form Grid Layout

```svelte
<form class="space-y-6">
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div>
      <label for="firstName" class="label">First Name</label>
      <input type="text" id="firstName" class="input variant-form w-full" />
    </div>
    
    <div>
      <label for="lastName" class="label">Last Name</label>
      <input type="text" id="lastName" class="input variant-form w-full" />
    </div>
    
    <div>
      <label for="email" class="label">Email</label>
      <input type="email" id="email" class="input variant-form w-full" />
    </div>
    
    <div>
      <label for="phone" class="label">Phone</label>
      <input type="tel" id="phone" class="input variant-form w-full" />
    </div>
  </div>
  
  <div>
    <label for="address" class="label">Address</label>
    <input type="text" id="address" class="input variant-form w-full" />
  </div>
  
  <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
    <div>
      <label for="city" class="label">City</label>
      <input type="text" id="city" class="input variant-form w-full" />
    </div>
    
    <div>
      <label for="state" class="label">State</label>
      <select id="state" class="select variant-form w-full">
        <option value="">Select...</option>
        <option value="ca">California</option>
        <option value="ny">New York</option>
      </select>
    </div>
    
    <div>
      <label for="zip" class="label">ZIP Code</label>
      <input type="text" id="zip" class="input variant-form w-full" />
    </div>
  </div>
</form>
```

## Checkboxes and Radios

```svelte
<script lang="ts">
  let preferences = $state({
    notifications: {
      email: true,
      sms: false,
      push: true
    },
    theme: 'light'
  });
</script>

<form class="space-y-6">
  <!-- Checkboxes -->
  <fieldset>
    <legend class="label">Notification Preferences</legend>
    <div class="space-y-2">
      <label class="flex items-center gap-3 cursor-pointer">
        <input 
          type="checkbox" 
          bind:checked={preferences.notifications.email}
          class="checkbox"
        />
        <span>Email notifications</span>
      </label>
      
      <label class="flex items-center gap-3 cursor-pointer">
        <input 
          type="checkbox" 
          bind:checked={preferences.notifications.sms}
          class="checkbox"
        />
        <span>SMS notifications</span>
      </label>
      
      <label class="flex items-center gap-3 cursor-pointer">
        <input 
          type="checkbox" 
          bind:checked={preferences.notifications.push}
          class="checkbox"
        />
        <span>Push notifications</span>
      </label>
    </div>
  </fieldset>
  
  <!-- Radio buttons -->
  <fieldset>
    <legend class="label">Theme</legend>
    <div class="flex gap-4">
      <label class="flex items-center gap-2 cursor-pointer">
        <input 
          type="radio" 
          name="theme" 
          value="light"
          bind:group={preferences.theme}
          class="radio"
        />
        <span>Light</span>
      </label>
      
      <label class="flex items-center gap-2 cursor-pointer">
        <input 
          type="radio" 
          name="theme" 
          value="dark"
          bind:group={preferences.theme}
          class="radio"
        />
        <span>Dark</span>
      </label>
      
      <label class="flex items-center gap-2 cursor-pointer">
        <input 
          type="radio" 
          name="theme" 
          value="system"
          bind:group={preferences.theme}
          class="radio"
        />
        <span>System</span>
      </label>
    </div>
  </fieldset>
  
  <!-- Switch -->
  <div class="flex items-center justify-between">
    <div>
      <p class="font-medium">Dark Mode</p>
      <p class="text-sm text-surface-500">Enable dark mode for the dashboard</p>
    </div>
    <label class="switch">
      <input type="checkbox" bind:checked={preferences.theme} />
      <span class="switch-slider"></span>
    </label>
  </div>
</form>
```

## File Upload

```svelte
<script lang="ts">
  let files = $state<File[]>([]);
  let dragging = $state(false);
  
  function handleDrop(e: DragEvent) {
    e.preventDefault();
    dragging = false;
    
    if (e.dataTransfer?.files) {
      files = [...files, ...Array.from(e.dataTransfer.files)];
    }
  }
  
  function handleFileSelect(e: Event) {
    const target = e.target as HTMLInputElement;
    if (target.files) {
      files = [...files, ...Array.from(target.files)];
    }
  }
  
  function removeFile(index: number) {
    files = files.filter((_, i) => i !== index);
  }
</script>

<div class="space-y-4">
  <!-- Drop zone -->
  <div 
    class="border-2 border-dashed rounded-xl p-8 text-center transition-colors
      {dragging 
        ? 'border-primary-500 bg-primary-500/10' 
        : 'border-surface-200-800 hover:border-surface-300-700'}"
    ondragover={(e) => { e.preventDefault(); dragging = true; }}
    ondragleave={() => dragging = false}
    ondrop={handleDrop}
  >
    <svg class="w-12 h-12 mx-auto text-surface-500 mb-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">
      <path d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/>
    </svg>
    <p class="text-surface-500 mb-2">Drag and drop files here</p>
    <p class="text-sm text-surface-500">or</p>
    <label class="btn variant-outline mt-2 cursor-pointer">
      Browse Files
      <input 
        type="file" 
        class="hidden" 
        multiple
        onchange={handleFileSelect}
      />
    </label>
  </div>
  
  <!-- File list -->
  {#if files.length > 0}
    <ul class="space-y-2">
      {#each files as file, i}
        <li class="flex items-center justify-between p-3 bg-surface-100-900 rounded-lg">
          <div class="flex items-center gap-3">
            <svg class="w-5 h-5 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
            <div>
              <p class="text-sm font-medium">{file.name}</p>
              <p class="text-xs text-surface-500">{(file.size / 1024).toFixed(1)} KB</p>
            </div>
          </div>
          <button 
            type="button"
            onclick={() => removeFile(i)}
            class="btn btn-sm variant-ghost text-error-500"
          >
            Remove
          </button>
        </li>
      {/each}
    </ul>
  {/if}
</div>
```

## Multi-Step Form

```svelte
<script lang="ts">
  let currentStep = $state(0);
  
  const steps = [
    { title: 'Account', description: 'Basic info' },
    { title: 'Profile', description: 'Personal details' },
    { title: 'Preferences', description: 'Settings' },
    { title: 'Complete', description: 'Review' }
  ];
  
  let formData = $state({
    email: '',
    password: '',
    firstName: '',
    lastName: '',
    bio: '',
    notifications: true,
    theme: 'light'
  });
  
  function nextStep() {
    if (currentStep < steps.length - 1) currentStep++;
  }
  
  function prevStep() {
    if (currentStep > 0) currentStep--;
  }
</script>

<div class="max-w-2xl mx-auto">
  <!-- Progress steps -->
  <div class="mb-8">
    <div class="flex items-center justify-between">
      {#each steps as step, i}
        <div class="flex items-center">
          <div 
            class="w-10 h-10 rounded-full flex items-center justify-center text-sm font-medium
              {i <= currentStep 
                ? 'bg-primary-500 text-white' 
                : 'bg-surface-200-800 text-surface-500'}"
          >
            {#if i < currentStep}
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                <path d="M5 13l4 4L19 7"/>
              </svg>
            {:else}
              {i + 1}
            {/if}
          </div>
          {#if i < steps.length - 1}
            <div 
              class="w-24 h-1 mx-2
                {i < currentStep ? 'bg-primary-500' : 'bg-surface-200-800'}"
            ></div>
          {/if}
        </div>
      {/each}
    </div>
  </div>
  
  <!-- Step content -->
  <div class="bg-surface-50-950 border border-surface-200-800 rounded-xl p-6">
    {#if currentStep === 0}
      <h2 class="text-xl font-bold mb-4">Account Information</h2>
      <div class="space-y-4">
        <div>
          <label class="label">Email</label>
          <input type="email" bind:value={formData.email} class="input variant-form w-full" />
        </div>
        <div>
          <label class="label">Password</label>
          <input type="password" bind:value={formData.password} class="input variant-form w-full" />
        </div>
      </div>
    {:else if currentStep === 1}
      <h2 class="text-xl font-bold mb-4">Profile Details</h2>
      <div class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="label">First Name</label>
            <input type="text" bind:value={formData.firstName} class="input variant-form w-full" />
          </div>
          <div>
            <label class="label">Last Name</label>
            <input type="text" bind:value={formData.lastName} class="input variant-form w-full" />
          </div>
        </div>
        <div>
          <label class="label">Bio</label>
          <textarea bind:value={formData.bio} class="textarea variant-form w-full" rows="4"></textarea>
        </div>
      </div>
    {:else if currentStep === 2}
      <h2 class="text-xl font-bold mb-4">Preferences</h2>
      <div class="space-y-4">
        <label class="flex items-center gap-3">
          <input type="checkbox" bind:checked={formData.notifications} class="checkbox" />
          <span>Enable email notifications</span>
        </label>
      </div>
    {:else}
      <h2 class="text-xl font-bold mb-4">Review & Complete</h2>
      <div class="space-y-4">
        <p class="text-surface-500">Review your information before submitting.</p>
        <pre class="bg-surface-100-900 p-4 rounded-lg text-sm overflow-auto">{JSON.stringify(formData, null, 2)}</pre>
      </div>
    {/if}
    
    <!-- Navigation -->
    <div class="flex justify-between mt-6 pt-6 border-t border-surface-200-800">
      <button 
        type="button"
        class="btn variant-ghost"
        onclick={prevStep}
        disabled={currentStep === 0}
      >
        Previous
      </button>
      
      {#if currentStep === steps.length - 1}
        <button type="button" class="btn variant-filled-primary">
          Complete
        </button>
      {:else}
        <button type="button" class="btn variant-filled-primary" onclick={nextStep}>
          Next
        </button>
      {/if}
    </div>
  </div>
</div>

<style>
  .label {
    @apply block text-sm font-medium text-surface-950-50 mb-2;
  }
</style>
```

## Search Input with Icon

```svelte
<div class="relative">
  <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-surface-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
  </svg>
  <input 
    type="search"
    placeholder="Search..."
    class="input variant-form pl-10 w-full"
  />
</div>
```

## Input with Button

```svelte
<div class="flex gap-2">
  <input 
    type="text"
    placeholder="Enter value..."
    class="input variant-form flex-1"
  />
  <button class="btn variant-filled-primary">Add</button>
</div>
```

## Inline Edit

```svelte
<script lang="ts">
  let value = $state('John Doe');
  let editing = $state(false);
  let tempValue = $state('');
  
  function startEdit() {
    tempValue = value;
    editing = true;
  }
  
  function save() {
    value = tempValue;
    editing = false;
  }
  
  function cancel() {
    editing = false;
  }
</script>

<div class="flex items-center gap-2">
  {#if editing}
    <input 
      type="text"
      bind:value={tempValue}
      class="input variant-form"
      autofocus
    />
    <button class="btn btn-sm variant-ghost text-success-500" onclick={save}>Save</button>
    <button class="btn btn-sm variant-ghost text-error-500" onclick={cancel}>Cancel</button>
  {:else}
    <span>{value}</span>
    <button class="btn btn-sm variant-ghost" onclick={startEdit}>Edit</button>
  {/if}
</div>
```