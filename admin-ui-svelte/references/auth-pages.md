# Auth Pages Reference

Authentication page templates including login, register, and forgot password.

## Login Page

```svelte
<script lang="ts">
  let email = $state('');
  let password = $state('');
  let remember = $state(false);
  let loading = $state(false);
  let error = $state('');
  
  async function handleSubmit(e: Event) {
    e.preventDefault();
    loading = true;
    error = '';
    
    try {
      // Add your authentication logic here
      await new Promise(resolve => setTimeout(resolve, 1000));
      // Redirect on success
    } catch (e) {
      error = 'Invalid email or password';
    } finally {
      loading = false;
    }
  }
</script>

<div class="min-h-screen bg-surface-50-950 flex items-center justify-center p-4">
  <div class="w-full max-w-md">
    <!-- Logo -->
    <div class="text-center mb-8">
      <div class="w-12 h-12 bg-primary-500 rounded-xl mx-auto mb-4 flex items-center justify-center">
        <svg class="w-6 h-6 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
        </svg>
      </div>
      <h1 class="text-2xl font-bold text-surface-950-50">Welcome back</h1>
      <p class="text-surface-500 mt-1">Sign in to your account</p>
    </div>
    
    <!-- Form -->
    <div class="bg-surface-100-900 border border-surface-200-800 rounded-2xl p-8">
      {#if error}
        <div class="bg-error-500/10 border border-error-500/20 text-error-500 px-4 py-3 rounded-lg mb-6 text-sm">
          {error}
        </div>
      {/if}
      
      <form onsubmit={handleSubmit} class="space-y-5">
        <div>
          <label for="email" class="block text-sm font-medium text-surface-950-50 mb-2">
            Email address
          </label>
          <input 
            type="email" 
            id="email"
            bind:value={email}
            class="input variant-form w-full"
            placeholder="you@example.com"
            required
          />
        </div>
        
        <div>
          <label for="password" class="block text-sm font-medium text-surface-950-50 mb-2">
            Password
          </label>
          <input 
            type="password" 
            id="password"
            bind:value={password}
            class="input variant-form w-full"
            placeholder="Enter your password"
            required
          />
        </div>
        
        <div class="flex items-center justify-between">
          <label class="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" bind:checked={remember} class="checkbox" />
            <span class="text-sm text-surface-500">Remember me</span>
          </label>
          
          <a href="/forgot-password" class="text-sm text-primary-500 hover:underline">
            Forgot password?
          </a>
        </div>
        
        <button 
          type="submit" 
          class="btn variant-filled-primary w-full"
          disabled={loading}
        >
          {#if loading}
            <svg class="w-5 h-5 animate-spin" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
            </svg>
            Signing in...
          {:else}
            Sign in
          {/if}
        </button>
      </form>
      
      <!-- Divider -->
      <div class="relative my-6">
        <div class="absolute inset-0 flex items-center">
          <div class="w-full border-t border-surface-200-800"></div>
        </div>
        <div class="relative flex justify-center text-sm">
          <span class="px-4 bg-surface-100-900 text-surface-500">Or continue with</span>
        </div>
      </div>
      
      <!-- Social login -->
      <div class="grid grid-cols-2 gap-3">
        <button class="btn variant-outline flex items-center justify-center gap-2">
          <svg class="w-5 h-5" viewBox="0 0 24 24">
            <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
            <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          Google
        </button>
        <button class="btn variant-outline flex items-center justify-center gap-2">
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
          </svg>
          GitHub
        </button>
      </div>
    </div>
    
    <!-- Sign up link -->
    <p class="text-center mt-6 text-surface-500">
      Don't have an account? 
      <a href="/register" class="text-primary-500 hover:underline">Sign up</a>
    </p>
  </div>
</div>
```

## Register Page

```svelte
<script lang="ts">
  let formData = $state({
    name: '',
    email: '',
    password: '',
    confirmPassword: ''
  });
  
  let errors = $state<Record<string, string>>({});
  let loading = $state(false);
  
  function validate(): boolean {
    errors = {};
    
    if (!formData.name) errors.name = 'Name is required';
    if (!formData.email) errors.email = 'Email is required';
    if (!formData.password) errors.password = 'Password is required';
    if (formData.password.length < 8) errors.password = 'Password must be at least 8 characters';
    if (formData.password !== formData.confirmPassword) {
      errors.confirmPassword = 'Passwords do not match';
    }
    
    return Object.keys(errors).length === 0;
  }
  
  async function handleSubmit(e: Event) {
    e.preventDefault();
    
    if (!validate()) return;
    
    loading = true;
    try {
      // Registration logic
      await new Promise(resolve => setTimeout(resolve, 1000));
    } catch (e) {
      errors.email = 'Email already exists';
    } finally {
      loading = false;
    }
  }
</script>

<div class="min-h-screen bg-surface-50-950 flex items-center justify-center p-4">
  <div class="w-full max-w-md">
    <!-- Header -->
    <div class="text-center mb-8">
      <h1 class="text-2xl font-bold text-surface-950-50">Create account</h1>
      <p class="text-surface-500 mt-1">Get started with your free account</p>
    </div>
    
    <!-- Form -->
    <div class="bg-surface-100-900 border border-surface-200-800 rounded-2xl p-8">
      <form onsubmit={handleSubmit} class="space-y-5">
        <div>
          <label for="name" class="block text-sm font-medium text-surface-950-50 mb-2">
            Full Name
          </label>
          <input 
            type="text" 
            id="name"
            bind:value={formData.name}
            class="input variant-form w-full {errors.name ? 'border-error-500' : ''}"
            placeholder="John Doe"
          />
          {#if errors.name}
            <p class="text-sm text-error-500 mt-1">{errors.name}</p>
          {/if}
        </div>
        
        <div>
          <label for="email" class="block text-sm font-medium text-surface-950-50 mb-2">
            Email address
          </label>
          <input 
            type="email" 
            id="email"
            bind:value={formData.email}
            class="input variant-form w-full {errors.email ? 'border-error-500' : ''}"
            placeholder="you@example.com"
          />
          {#if errors.email}
            <p class="text-sm text-error-500 mt-1">{errors.email}</p>
          {/if}
        </div>
        
        <div>
          <label for="password" class="block text-sm font-medium text-surface-950-50 mb-2">
            Password
          </label>
          <input 
            type="password" 
            id="password"
            bind:value={formData.password}
            class="input variant-form w-full {errors.password ? 'border-error-500' : ''}"
            placeholder="Create a password"
          />
          {#if errors.password}
            <p class="text-sm text-error-500 mt-1">{errors.password}</p>
          {/if}
        </div>
        
        <div>
          <label for="confirmPassword" class="block text-sm font-medium text-surface-950-50 mb-2">
            Confirm Password
          </label>
          <input 
            type="password" 
            id="confirmPassword"
            bind:value={formData.confirmPassword}
            class="input variant-form w-full {errors.confirmPassword ? 'border-error-500' : ''}"
            placeholder="Confirm your password"
          />
          {#if errors.confirmPassword}
            <p class="text-sm text-error-500 mt-1">{errors.confirmPassword}</p>
          {/if}
        </div>
        
        <div class="flex items-start gap-2">
          <input type="checkbox" id="terms" class="checkbox mt-1" required />
          <label for="terms" class="text-sm text-surface-500">
            I agree to the <a href="/terms" class="text-primary-500 hover:underline">Terms of Service</a> 
            and <a href="/privacy" class="text-primary-500 hover:underline">Privacy Policy</a>
          </label>
        </div>
        
        <button 
          type="submit" 
          class="btn variant-filled-primary w-full"
          disabled={loading}
        >
          {#if loading}
            Creating account...
          {:else}
            Create account
          {/if}
        </button>
      </form>
    </div>
    
    <!-- Sign in link -->
    <p class="text-center mt-6 text-surface-500">
      Already have an account? 
      <a href="/login" class="text-primary-500 hover:underline">Sign in</a>
    </p>
  </div>
</div>
```

## Forgot Password Page

```svelte
<script lang="ts">
  let email = $state('');
  let loading = $state(false);
  let submitted = $state(false);
  let error = $state('');
  
  async function handleSubmit(e: Event) {
    e.preventDefault();
    loading = true;
    error = '';
    
    try {
      // Send reset email logic
      await new Promise(resolve => setTimeout(resolve, 1000));
      submitted = true;
    } catch (e) {
      error = 'Failed to send reset email. Please try again.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="min-h-screen bg-surface-50-950 flex items-center justify-center p-4">
  <div class="w-full max-w-md">
    {#if !submitted}
      <!-- Request form -->
      <div class="text-center mb-8">
        <h1 class="text-2xl font-bold text-surface-950-50">Forgot password?</h1>
        <p class="text-surface-500 mt-1">No worries, we'll send you reset instructions.</p>
      </div>
      
      <div class="bg-surface-100-900 border border-surface-200-800 rounded-2xl p-8">
        {#if error}
          <div class="bg-error-500/10 border border-error-500/20 text-error-500 px-4 py-3 rounded-lg mb-6 text-sm">
            {error}
          </div>
        {/if}
        
        <form onsubmit={handleSubmit} class="space-y-5">
          <div>
            <label for="email" class="block text-sm font-medium text-surface-950-50 mb-2">
              Email address
            </label>
            <input 
              type="email" 
              id="email"
              bind:value={email}
              class="input variant-form w-full"
              placeholder="you@example.com"
              required
            />
          </div>
          
          <button 
            type="submit" 
            class="btn variant-filled-primary w-full"
            disabled={loading}
          >
            {#if loading}
              Sending...
            {:else}
              Reset password
            {/if}
          </button>
        </form>
      </div>
      
      <p class="text-center mt-6">
        <a href="/login" class="text-surface-500 hover:text-surface-950-50 flex items-center justify-center gap-2">
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
          </svg>
          Back to login
        </a>
      </p>
    {:else}
      <!-- Success state -->
      <div class="text-center">
        <div class="w-16 h-16 bg-success-500/20 rounded-full mx-auto mb-6 flex items-center justify-center">
          <svg class="w-8 h-8 text-success-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
          </svg>
        </div>
        
        <h1 class="text-2xl font-bold text-surface-950-50">Check your email</h1>
        <p class="text-surface-500 mt-2 mb-6">
          We sent a password reset link to<br />
          <span class="text-surface-950-50 font-medium">{email}</span>
        </p>
        
        <a href="/login" class="btn variant-filled-primary w-full">
          Back to login
        </a>
        
        <p class="text-surface-500 text-sm mt-6">
          Didn't receive the email? 
          <button 
            onclick={() => { submitted = false; }}
            class="text-primary-500 hover:underline"
          >
            Click to resend
          </button>
        </p>
      </div>
    {/if}
  </div>
</div>
```

## Reset Password Page

```svelte
<script lang="ts">
  let password = $state('');
  let confirmPassword = $state('');
  let loading = $state(false);
  let error = $state('');
  let success = $state(false);
  
  async function handleSubmit(e: Event) {
    e.preventDefault();
    
    if (password !== confirmPassword) {
      error = 'Passwords do not match';
      return;
    }
    
    if (password.length < 8) {
      error = 'Password must be at least 8 characters';
      return;
    }
    
    loading = true;
    error = '';
    
    try {
      // Reset password logic
      await new Promise(resolve => setTimeout(resolve, 1000));
      success = true;
    } catch (e) {
      error = 'Failed to reset password. The link may have expired.';
    } finally {
      loading = false;
    }
  }
</script>

<div class="min-h-screen bg-surface-50-950 flex items-center justify-center p-4">
  <div class="w-full max-w-md">
    {#if !success}
      <div class="text-center mb-8">
        <h1 class="text-2xl font-bold text-surface-950-50">Set new password</h1>
        <p class="text-surface-500 mt-1">Your new password must be different from previous passwords.</p>
      </div>
      
      <div class="bg-surface-100-900 border border-surface-200-800 rounded-2xl p-8">
        {#if error}
          <div class="bg-error-500/10 border border-error-500/20 text-error-500 px-4 py-3 rounded-lg mb-6 text-sm">
            {error}
          </div>
        {/if}
        
        <form onsubmit={handleSubmit} class="space-y-5">
          <div>
            <label for="password" class="block text-sm font-medium text-surface-950-50 mb-2">
              New Password
            </label>
            <input 
              type="password" 
              id="password"
              bind:value={password}
              class="input variant-form w-full"
              placeholder="Enter new password"
              required
            />
          </div>
          
          <div>
            <label for="confirmPassword" class="block text-sm font-medium text-surface-950-50 mb-2">
              Confirm Password
            </label>
            <input 
              type="password" 
              id="confirmPassword"
              bind:value={confirmPassword}
              class="input variant-form w-full"
              placeholder="Confirm new password"
              required
            />
          </div>
          
          <button 
            type="submit" 
            class="btn variant-filled-primary w-full"
            disabled={loading}
          >
            {#if loading}
              Resetting...
            {:else}
              Reset password
            {/if}
          </button>
        </form>
      </div>
    {:else}
      <div class="text-center">
        <div class="w-16 h-16 bg-success-500/20 rounded-full mx-auto mb-6 flex items-center justify-center">
          <svg class="w-8 h-8 text-success-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
        </div>
        
        <h1 class="text-2xl font-bold text-surface-950-50">Password reset!</h1>
        <p class="text-surface-500 mt-2 mb-6">
          Your password has been successfully reset.
        </p>
        
        <a href="/login" class="btn variant-filled-primary w-full">
          Continue to login
        </a>
      </div>
    {/if}
  </div>
</div>
```

## Two-Column Auth Layout

```svelte
<script lang="ts">
  let { children } = $props();
</script>

<div class="min-h-screen grid lg:grid-cols-2">
  <!-- Left side - Form -->
  <div class="flex items-center justify-center p-8">
    <div class="w-full max-w-md">
      {@render children()}
    </div>
  </div>
  
  <!-- Right side - Image/Branding -->
  <div class="hidden lg:block relative bg-gradient-to-br from-primary-600 to-primary-900">
    <div class="absolute inset-0 flex flex-col items-center justify-center p-12 text-white">
      <h2 class="text-3xl font-bold mb-4">Welcome to Admin Panel</h2>
      <p class="text-white/80 text-center max-w-md">
        Manage your entire business from one powerful dashboard. 
        Track analytics, manage users, and more.
      </p>
      
      <!-- Features list -->
      <ul class="mt-12 space-y-4 text-white/90">
        <li class="flex items-center gap-3">
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M5 13l4 4L19 7"/>
          </svg>
          Real-time analytics
        </li>
        <li class="flex items-center gap-3">
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M5 13l4 4L19 7"/>
          </svg>
          User management
        </li>
        <li class="flex items-center gap-3">
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M5 13l4 4L19 7"/>
          </svg>
          Secure & reliable
        </li>
      </ul>
    </div>
  </div>
</div>
```