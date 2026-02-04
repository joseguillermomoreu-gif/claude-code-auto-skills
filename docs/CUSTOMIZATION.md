# Guía de Personalización

Esta guía te ayudará a personalizar Claude Code Auto-Skills según tus necesidades específicas.

---

## 🎯 Niveles de Personalización

### Nivel 1: Ajustar Perfil Global
**Dificultad**: Fácil
**Tiempo**: 5-10 minutos
**Archivo**: `~/.claude/CLAUDE.md`

### Nivel 2: Modificar Skills Existentes
**Dificultad**: Media
**Tiempo**: 15-30 minutos
**Archivos**: `~/.claude/skills/*.md`

### Nivel 3: Crear Skills Propios
**Dificultad**: Media-Alta
**Tiempo**: 1-2 horas
**Archivos**: Nuevos skills en `~/.claude/skills/`

---

## 📝 Nivel 1: Ajustar Perfil Global

### Qué Personalizar en CLAUDE.md

#### 1. Stack Tecnológico

Edita la sección "Stack Tecnológico" con tus herramientas:

```bash
vim ~/.claude/CLAUDE.md
```

```markdown
## Stack Tecnológico

### Backend (Tu Expertise)
- **Framework**: Laravel 10 (en lugar de Symfony)
- **ORM**: Eloquent (en lugar de Doctrine)
- ...

### Frontend (Si aplica)
- **Framework**: Vue 3 (en lugar de React)
- ...
```

#### 2. Preferencias de Código

Modifica según tu estilo:

```markdown
## Preferencias de Código

### Principios Generales
- **Architecture**: CQRS + Event Sourcing (tu preferencia)
- **Testing**: TDD estricto (tu metodología)
- **Comments**: JSDoc completo en funciones públicas (tu convención)
```

#### 3. Naming Conventions

Ajusta a tu equipo:

```markdown
### Naming Conventions

#### PHP/Laravel (por ejemplo)
- Controllers: `UserController` (sufijo obligatorio)
- Models: `User` (singular, sin sufijo)
- Services: `UserService`
- Repositories: `UserRepository`
- Variables: `$camelCase`
```

#### 4. Detección Automática de Skills

Añade nuevos patrones de detección:

```markdown
## 🚀 Sistema de Auto-Carga de Skills

**a) Detecta automáticamente**:
```bash
composer.json          → php-symfony.md
pyproject.toml         → python.md
# Añade tus propios:
go.mod                 → golang.md (si lo creas)
Cargo.toml             → rust.md (si lo creas)
package.json + vue     → vue.md (si lo creas)
```

---

## 🔧 Nivel 2: Modificar Skills Existentes

### Por Qué Modificar

- Añadir ejemplos de tu stack específico
- Actualizar a nuevas versiones
- Añadir patterns que usas frecuentemente
- Remover secciones que no usas

### Cómo Modificar un Skill

#### Ejemplo: Añadir sección a php-symfony.md

```bash
# 1. Abre el skill
vim ~/.claude/skills/php-symfony.md

# 2. Encuentra dónde insertar (antes de "Mantenimiento")
# 3. Añade tu sección

## API Platform (Mi Sección Nueva)

### Setup
```yaml
# config/packages/api_platform.yaml
api_platform:
    title: 'My API'
    version: '1.0.0'
```

### Uso con Entities
```php
use ApiPlatform\Metadata\ApiResource;

#[ApiResource]
class Product
{
    // ...
}
```

# 4. Guarda y sal
```

#### Ejemplo: Actualizar versión en typescript.md

```bash
vim ~/.claude/skills/typescript.md

# Busca la sección de metadata
> **Versión**: TypeScript 5.x
# Cambia a:
> **Versión**: TypeScript 5.4
> **Última actualización**: 2026-02-04 (Tu nombre)

# Añade nota al final:
## Changelog
- 2026-02-04: Actualizado a TypeScript 5.4, añadidos decorators
```

### Buenas Prácticas al Modificar

✅ **DO**:
- Mantén la estructura existente
- Añade secciones nuevas antes de "Mantenimiento"
- Documenta tus cambios en comentarios o changelog
- Usa ejemplos reales de tu código

❌ **DON'T**:
- No elimines la sección "Mantenimiento de este Skill"
- No cambies radicalmente la estructura
- No copies/pegues código sin contexto
- No añadas información contradictoria

---

## 🚀 Nivel 3: Crear Skills Propios

### Casos de Uso

- Stack no incluido (Laravel, Django, NestJS, etc.)
- Framework específico (API Platform, GraphQL, gRPC)
- Herramientas internas de tu empresa
- Patterns muy específicos de tu arquitectura

### Plantilla de Skill

```bash
# 1. Crea el archivo
vim ~/.claude/skills/mi-skill.md

# 2. Usa esta plantilla:
```

```markdown
# [Nombre del Skill] - [Descripción Breve]

> **Stack/Versión**: [Info técnica]
> **Última actualización**: YYYY-MM-DD
> **Autor**: [Tu nombre]

## Introducción

[Explicación de qué cubre este skill y por qué es útil]

**Ideal para**:
- Proyectos que usan X
- Cuando necesitas Y
- Si trabajas con Z

---

## Setup Básico

### Instalación

```bash
# Comandos de instalación
```

### Configuración Mínima

```language
// Ejemplo de configuración
```

---

## Conceptos Fundamentales

### Concepto 1: [Nombre]

[Explicación]

```language
// Ejemplo de código funcional
```

### Concepto 2: [Nombre]

[Explicación]

```language
// Ejemplo
```

---

## Patterns Comunes

### Pattern 1: [Nombre del Pattern]

**Cuándo usar**: [Situación]

```language
// Implementación
```

### Pattern 2: [Nombre del Pattern]

**Cuándo usar**: [Situación]

```language
// Implementación
```

---

## Best Practices

1. **[Práctica 1]**: [Explicación del por qué]
   ```language
   // Ejemplo
   ```

2. **[Práctica 2]**: [Explicación]
   ```language
   // Ejemplo
   ```

---

## Naming Conventions

```language
// Ejemplos de naming
class MyClass           // Descripción
function myFunction()   // Descripción
const MY_CONSTANT       // Descripción
```

---

## Testing

### Setup de Tests

```bash
# Comandos para testing
```

### Ejemplo de Test

```language
// Test funcional
```

---

## Comandos Útiles

```bash
# Desarrollo
comando1    # Descripción

# Testing
comando2    # Descripción

# Deployment
comando3    # Descripción
```

---

## Recursos

- [Documentación oficial](URL)
- [Tutorial](URL)
- [Cheatsheet](URL)

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- Detectes nueva versión de [herramienta/framework]
- Encuentres mejores patterns
- Veas errores o información desactualizada

**Preserva siempre**:
- [Qué características mantener]
- [Convenciones establecidas]

**Usa Context7**:
```language
resolve-library-id: "[librería]"
query-docs: "[query de ejemplo]"
```
```

---

### Ejemplo Real: Crear skill para Laravel

```bash
vim ~/.claude/skills/php-laravel.md
```

```markdown
# PHP/Laravel - Eloquent y Patterns

> **Stack**: Laravel 11.x + PHP 8.3
> **Última actualización**: 2026-02-04

## Introducción

Skill enfocado en Laravel con Eloquent ORM, siguiendo mejores prácticas
de la comunidad Laravel.

**Ideal para**:
- Proyectos Laravel 10.x o 11.x
- APIs REST con Laravel
- Aplicaciones CRUD con Eloquent

---

## Setup Básico

### Instalación

```bash
composer create-project laravel/laravel my-project
cd my-project
php artisan serve
```

### Configuración Mínima

```php
// .env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=
```

---

## Eloquent Models

### Definición de Model

```php
<?php
declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Model
{
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
```

---

## Controllers

### Resource Controller

```php
<?php
declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\User;
use App\Http\Requests\StoreUserRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class UserController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return UserResource::collection(
            User::paginate(15)
        );
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = User::create($request->validated());

        return response()->json(
            new UserResource($user),
            201
        );
    }

    public function show(User $user): UserResource
    {
        return new UserResource($user);
    }

    public function update(StoreUserRequest $request, User $user): UserResource
    {
        $user->update($request->validated());

        return new UserResource($user);
    }

    public function destroy(User $user): JsonResponse
    {
        $user->delete();

        return response()->json(null, 204);
    }
}
```

---

## Form Requests

```php
<?php
declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'El email ya está registrado',
            'password.min' => 'La contraseña debe tener al menos 8 caracteres',
        ];
    }
}
```

---

## API Resources

```php
<?php
declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at?->toISOString(),
            'orders_count' => $this->whenCounted('orders'),
            'orders' => OrderResource::collection($this->whenLoaded('orders')),
        ];
    }
}
```

---

## Testing

### Feature Test

```php
<?php
declare(strict_types=1);

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_user(): void
    {
        $response = $this->postJson('/api/users', [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => ['id', 'name', 'email', 'created_at']
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
        ]);
    }
}
```

---

## Comandos Útiles

```bash
# Desarrollo
php artisan serve                       # Dev server
php artisan tinker                      # REPL

# Database
php artisan migrate                     # Run migrations
php artisan migrate:fresh --seed        # Reset + seed
php artisan make:migration create_users_table

# Código
php artisan make:model User -mfsc       # Model + migration + factory + seeder + controller
php artisan make:request StoreUserRequest
php artisan make:resource UserResource

# Testing
php artisan test                        # PHPUnit
php artisan test --coverage             # Con coverage

# Quality
./vendor/bin/phpstan analyse            # Static analysis
./vendor/bin/pint                       # Code style (Laravel Pint)
```

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- Laravel lance nueva versión mayor
- Cambien best practices en la comunidad Laravel
- Detectes patterns obsoletos

**Preserva siempre**:
- Type safety con declare(strict_types=1)
- Resource Controllers pattern
- Form Requests para validación

**Usa Context7**:
```php
resolve-library-id: "laravel/laravel"
query-docs: "latest Laravel features"
```
```

---

## 🔄 Activar tu Nuevo Skill

### 1. Añadir a detección automática

Edita `~/.claude/CLAUDE.md`:

```markdown
**a) Detecta automáticamente**:
```bash
composer.json          → php-symfony.md
# Añade:
composer.json + laravel/framework → php-laravel.md  # Tu nuevo skill
```

### 2. Probar en un proyecto Laravel

```bash
cd ~/mi-proyecto-laravel
claude

# Primera interacción:
> "Ayúdame a crear un UserController"

🔍 Analizando proyecto...
📂 Detectado: composer.json (Laravel)

📚 Skills disponibles:
1. php-laravel.md  # ¡Tu skill aparece!

¿Cargar? (s/n): s

✅ Skill cargado: php-laravel
💾 MEMORY.md creado
```

---

## 💡 Tips de Personalización

### 1. Skills Específicos de Empresa

Si tu empresa tiene patterns propios:

```bash
vim ~/.claude/skills/empresa-patterns.md
```

```markdown
# [NombreEmpresa] - Internal Patterns

## API Response Format

Todas las APIs deben retornar:

```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "timestamp": "2026-02-04T10:00:00Z",
    "version": "1.0"
  }
}
```

## Error Handling

[Patterns específicos de tu empresa]
```

### 2. Combinar Skills

En proyectos complejos, combina múltiples skills en MEMORY.md:

```markdown
# Skills Configurados - Microservicio de Pagos

## Skills Activos
- php-laravel.md          # Backend
- typescript.md           # Admin panel
- openai.md               # Fraud detection con ML
- bash-scripts.md         # Deploy scripts
- empresa-patterns.md     # Internal conventions
```

### 3. Override Temporal

Si en un proyecto específico necesitas ignorar una convención global:

```markdown
# proyecto/MEMORY.md

## Skills Activos
- php-symfony.md

## Excepciones para este Proyecto
- **Naming**: En este proyecto usamos sufijo `Manager` en lugar de `Service`
  - Ejemplo: `UserManager` en lugar de `UserService`
- **Testing**: Coverage mínimo 90% (en lugar del 80% global)
```

---

## ❓ FAQ de Personalización

### ¿Puedo desactivar un skill permanentemente?

Sí, simplemente no lo cargues en ningún proyecto. O elimínalo:

```bash
rm ~/.claude/skills/skill-que-no-uso.md
```

### ¿Los cambios en CLAUDE.md afectan proyectos existentes?

No. Los proyectos con MEMORY.md ya creado mantienen su configuración.
CLAUDE.md solo afecta la detección inicial en proyectos nuevos.

### ¿Puedo tener diferentes versiones de un skill?

Sí, crea variantes:

```bash
~/.claude/skills/
├── php-symfony-hexagonal.md    # Con arquitectura hexagonal
├── php-symfony-simple.md        # Sin capas complejas
```

Y en CLAUDE.md, detecta según el contexto del proyecto.

### ¿Cómo comparto mis skills con mi equipo?

1. Crea un repo de tu empresa:
   ```
   empresa/claude-code-skills-internal
   ```

2. Fork de este proyecto + tus skills adicionales

3. Script de instalación del equipo:
   ```bash
   # install-team.sh
   ./install.sh
   cp skills-internal/*.md ~/.claude/skills/
   ```

---

## 🎓 Ejemplos Avanzados

Ver [examples/](../examples/) para:
- Skill para API GraphQL con TypeScript
- Skill para microservicios con Go
- Skill para DevOps con Terraform

---

**¿Dudas sobre personalización?** Abre un [issue](https://github.com/joseguillermomoreu-gif/claude-code-auto-skills/issues) con la etiqueta `[CUSTOMIZATION]`

---

*Última actualización: 2026-02-04*
