# Laravel - Modern PHP Framework

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Context7 enabled

---

## Introducción

Laravel es un framework PHP moderno con sintaxis elegante y herramientas potentes para desarrollo rápido.

**Características:**
- MVC architecture
- Eloquent ORM (Active Record)
- Blade templating engine
- Migration system
- Queue & Jobs
- Broadcasting & Events
- Testing con PHPUnit/Pest

**Versión actual:** Laravel 11+

---

## Estructura Básica

```
app/
├── Console/         # Comandos Artisan
├── Http/
│   ├── Controllers/
│   ├── Middleware/
│   └── Requests/    # Form Requests
├── Models/
└── Services/        # Business logic

routes/
├── web.php         # Web routes
├── api.php         # API routes
└── console.php     # Console commands

database/
├── migrations/
├── seeders/
└── factories/

resources/
├── views/          # Blade templates
└── js/             # Frontend assets

tests/
├── Feature/        # Feature tests
└── Unit/           # Unit tests
```

---

## Routing

### Web Routes

```php
// routes/web.php
use App\Http\Controllers\UserController;

// Basic route
Route::get('/', function () {
    return view('welcome');
});

// Controller action
Route::get('/users', [UserController::class, 'index']);
Route::get('/users/{id}', [UserController::class, 'show']);

// Route parameters
Route::get('/posts/{post}/comments/{comment}', function ($postId, $commentId) {
    return "Post: $postId, Comment: $commentId";
});

// Optional parameters
Route::get('/users/{name?}', function ($name = 'Guest') {
    return "Hello, $name";
});

// Route names
Route::get('/profile', [ProfileController::class, 'show'])->name('profile');

// Route groups
Route::prefix('admin')->group(function () {
    Route::get('/users', [AdminUserController::class, 'index']);
    Route::get('/posts', [AdminPostController::class, 'index']);
});

// Middleware
Route::middleware(['auth'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index']);
});
```

### API Routes

```php
// routes/api.php
use App\Http\Controllers\Api\ProductController;

Route::middleware('api')->group(function () {
    // RESTful resource
    Route::apiResource('products', ProductController::class);

    // Manual routes
    Route::get('/users', [UserController::class, 'index']);
    Route::post('/users', [UserController::class, 'store']);
});
```

---

## Controllers

```php
// app/Http/Controllers/UserController.php
namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function index(): JsonResponse
    {
        $users = User::all();
        return response()->json($users);
    }

    public function show(int $id): JsonResponse
    {
        $user = User::findOrFail($id);
        return response()->json($user);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8'
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => bcrypt($validated['password'])
        ]);

        return response()->json($user, 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'name' => 'string|max:255',
            'email' => 'email|unique:users,email,' . $id
        ]);

        $user->update($validated);

        return response()->json($user);
    }

    public function destroy(int $id): JsonResponse
    {
        $user = User::findOrFail($id);
        $user->delete();

        return response()->json(null, 204);
    }
}
```

---

## Eloquent ORM

### Models

```php
// app/Models/User.php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Model
{
    use SoftDeletes;

    protected $table = 'users';

    protected $fillable = ['name', 'email', 'password'];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'is_active' => 'boolean'
    ];

    // Relationships
    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }

    public function profile(): HasOne
    {
        return $this->hasOne(Profile::class);
    }

    // Accessors
    public function getFullNameAttribute(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }

    // Mutators
    public function setPasswordAttribute(string $value): void
    {
        $this->attributes['password'] = bcrypt($value);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
```

### Queries

```php
// Get all
$users = User::all();

// Find by ID
$user = User::find(1);
$user = User::findOrFail(1); // Throws 404 if not found

// Where clauses
$users = User::where('is_active', true)->get();
$users = User::where('votes', '>', 100)->get();
$users = User::whereIn('id', [1, 2, 3])->get();

// First/Latest
$user = User::first();
$user = User::latest()->first();

// Ordering
$users = User::orderBy('created_at', 'desc')->get();

// Limit & Offset
$users = User::take(10)->skip(20)->get();

// Pagination
$users = User::paginate(15);
$users = User::simplePaginate(15);

// Eager Loading
$users = User::with('posts')->get();
$users = User::with(['posts', 'profile'])->get();

// Counting
$count = User::count();
$active = User::where('is_active', true)->count();

// Aggregates
$max = User::max('votes');
$avg = User::avg('votes');

// Scopes
$users = User::active()->get();

// Chunk (memory efficient)
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // Process user
    }
});
```

### Relationships

```php
// One to Many
class Post extends Model
{
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }
}

// Many to Many
class Role extends Model
{
    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class);
    }
}

// Usage
$user->posts; // Get posts
$post->user; // Get user
$user->roles()->attach($roleId); // Attach role
$user->roles()->detach($roleId); // Detach role
```

---

## Migrations

```php
// database/migrations/2024_01_01_000000_create_users_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index('email');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};

// Run migrations
// php artisan migrate
// php artisan migrate:rollback
// php artisan migrate:fresh --seed
```

---

## Blade Templates

```blade
{{-- resources/views/users/index.blade.php --}}
@extends('layouts.app')

@section('title', 'Users')

@section('content')
    <h1>Users</h1>

    @if (count($users) > 0)
        <ul>
            @foreach ($users as $user)
                <li>
                    {{ $user->name }} - {{ $user->email }}

                    @if ($user->is_active)
                        <span class="badge">Active</span>
                    @endif
                </li>
            @endforeach
        </ul>
    @else
        <p>No users found</p>
    @endif

    {{-- Pagination --}}
    {{ $users->links() }}
@endsection

{{-- Components --}}
<x-alert type="success">
    User created successfully!
</x-alert>

{{-- Escape by default --}}
{{ $name }}  {{-- Escaped --}}
{!! $html !!}  {{-- Raw HTML --}}

{{-- Blade Directives --}}
@auth
    {{-- User is authenticated --}}
@endauth

@guest
    {{-- User is guest --}}
@endguest

@can('update', $post)
    {{-- User can update post --}}
@endcan
```

---

## Validation

### Form Request

```php
// app/Http/Requests/StoreUserRequest.php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Or check authorization
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', 'min:8', 'confirmed'],
            'age' => ['required', 'integer', 'min:18'],
            'role' => ['required', 'in:admin,user,moderator']
        ];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'Email is required',
            'email.email' => 'Invalid email format'
        ];
    }
}

// Controller
public function store(StoreUserRequest $request)
{
    $validated = $request->validated();
    // $validated is already validated
}
```

### Manual Validation

```php
$request->validate([
    'name' => 'required|string|max:255',
    'email' => 'required|email|unique:users'
]);
```

---

## Authentication

```php
// Login
use Illuminate\Support\Facades\Auth;

$credentials = $request->only('email', 'password');

if (Auth::attempt($credentials)) {
    $request->session()->regenerate();
    return redirect()->intended('/dashboard');
}

// Logout
Auth::logout();

// Get authenticated user
$user = Auth::user();
$userId = Auth::id();

// Check if authenticated
if (Auth::check()) {
    // User is logged in
}

// Manual login
Auth::login($user);
```

---

## Middleware

```php
// app/Http/Middleware/CheckAge.php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckAge
{
    public function handle(Request $request, Closure $next)
    {
        if ($request->age <= 18) {
            return redirect('home');
        }

        return $next($request);
    }
}

// Register in app/Http/Kernel.php
protected $middlewareAliases = [
    'check.age' => \App\Http\Middleware\CheckAge::class,
];

// Use in routes
Route::get('/adults-only', function () {
    //
})->middleware('check.age');
```

---

## Jobs & Queues

```php
// app/Jobs/SendEmailJob.php
namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendEmailJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        private User $user,
        private string $message
    ) {}

    public function handle(): void
    {
        // Send email logic
        Mail::to($this->user->email)->send(new WelcomeEmail($this->message));
    }
}

// Dispatch job
SendEmailJob::dispatch($user, 'Welcome!');

// Delayed dispatch
SendEmailJob::dispatch($user, 'Hello')->delay(now()->addMinutes(5));

// Run queue worker
// php artisan queue:work
```

---

## Testing

### Feature Test

```php
// tests/Feature/UserTest.php
namespace Tests\Feature;

use App\Models\User;
use Tests\TestCase;

class UserTest extends TestCase
{
    public function test_users_can_be_listed(): void
    {
        User::factory()->count(3)->create();

        $response = $this->get('/api/users');

        $response->assertStatus(200)
                 ->assertJsonCount(3);
    }

    public function test_user_can_be_created(): void
    {
        $userData = [
            'name' => 'John Doe',
            'email' => 'john@test.com',
            'password' => 'password123',
            'password_confirmation' => 'password123'
        ];

        $response = $this->post('/api/users', $userData);

        $response->assertStatus(201)
                 ->assertJsonFragment(['name' => 'John Doe']);

        $this->assertDatabaseHas('users', [
            'email' => 'john@test.com'
        ]);
    }

    public function test_user_cannot_be_created_with_invalid_data(): void
    {
        $response = $this->post('/api/users', [
            'name' => '',
            'email' => 'invalid-email'
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['name', 'email']);
    }
}
```

### Unit Test

```php
// tests/Unit/UserTest.php
namespace Tests\Unit;

use App\Models\User;
use Tests\TestCase;

class UserTest extends TestCase
{
    public function test_user_full_name_attribute(): void
    {
        $user = new User([
            'first_name' => 'John',
            'last_name' => 'Doe'
        ]);

        $this->assertEquals('John Doe', $user->full_name);
    }
}
```

---

## Artisan Commands

```bash
# Create
php artisan make:model User -mfc        # Model + Migration + Factory + Controller
php artisan make:controller UserController --resource
php artisan make:migration create_users_table
php artisan make:request StoreUserRequest
php artisan make:middleware CheckAge
php artisan make:job SendEmail

# Migrate
php artisan migrate
php artisan migrate:fresh --seed
php artisan migrate:rollback

# Cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Queue
php artisan queue:work
php artisan queue:restart

# Tinker (REPL)
php artisan tinker
```

---

## Best Practices

### ✅ DO

```php
// Service Pattern
class UserService
{
    public function createUser(array $data): User
    {
        return User::create($data);
    }
}

// Form Requests para validación
public function store(StoreUserRequest $request) {}

// Resource Controllers
Route::apiResource('users', UserController::class);

// Eager Loading (evitar N+1)
$users = User::with('posts')->get();

// Type hints
public function show(int $id): JsonResponse {}

// Factories para testing
User::factory()->count(10)->create();
```

### ❌ DON'T

```php
// Lógica en rutas
Route::get('/users', function () {
    // ❌ 50 líneas de lógica
});

// Queries en Blade
@foreach(DB::table('users')->get() as $user)  {{-- ❌ --}}

// Sin validación
$user = User::create($request->all()); // ❌

// N+1 problem
foreach ($users as $user) {
    echo $user->posts; // ❌ Query en loop
}

// Sin type hints
public function show($id) {} // ❌
```

---

## 🔄 Auto-Mantenimiento con Context7

**Library tracked:** `/laravel/laravel`

**Actualización automática:**
```
mcp__context7__resolve-library-id: libraryName="Laravel"
mcp__context7__query-docs: libraryId="/laravel/laravel", query="latest Laravel 11 features and best practices"
```

**Qué se actualiza:**
- ✅ Nuevas features de Laravel 11+
- ✅ Breaking changes
- ✅ Eloquent improvements
- ✅ Blade directives nuevas
- ✅ Security best practices

**Qué se preserva:**
- ✅ Arquitectura del proyecto
- ✅ Naming conventions
- ✅ Patrones establecidos (Services, Repositories)

**Frecuencia:** Automática cuando detecta nueva versión

**Última sync:** 2026-02-04
**Versión tracked:** Laravel 11.x

---

*Organismo viviente: Context7 + Experiencia comunitaria + Tu uso*
