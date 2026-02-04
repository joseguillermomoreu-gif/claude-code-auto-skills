# PHPStan - Static Analysis para PHP

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Context7 enabled

---

## Introducción

PHPStan es una herramienta de análisis estático para PHP que encuentra bugs en tu código sin ejecutarlo. Analiza el código para detectar errores de tipo, llamadas a métodos inexistentes, accesos a propiedades indefinidas, y muchos otros problemas.

**Cuándo usar:**
- Antes de commit (pre-commit hook)
- En CI/CD pipeline
- Durante desarrollo (IDE integration)
- Code reviews automatizados

---

## Niveles de Análisis

PHPStan tiene 10 niveles (0-9), cada uno más estricto:

### Level 0-2: Básico
```php
// Level 0: Solo errores críticos
$user->unknownMethod(); // ✓ Detecta

// Level 1: Posibles undefined variables
echo $variableNoDefinida; // ✓ Detecta

// Level 2: Unknown methods en todas las expresiones
$result = $obj->method()->unknownMethod(); // ✓ Detecta
```

### Level 3-5: Intermedio
```php
// Level 3: Return types
function getName(): string {
    return null; // ✗ Error
}

// Level 4: Dead code
if (false) {
    doSomething(); // ✗ Warning: unreachable
}

// Level 5: Argumentos faltantes
function greet(string $name, int $age) {}
greet('John'); // ✗ Error: missing argument
```

### Level 6-9: Estricto (RECOMENDADO)
```php
// Level 6: Type hints faltantes reportados
public function process($data) {} // ✗ Warning: missing type

// Level 7: Partially wrong union types
function getId(): int|null {
    return 'string'; // ✗ Error
}

// Level 8: Llamadas a nullable sin check
function process(?User $user) {
    echo $user->name; // ✗ Error: possible null
}

// Level 9: Mixed types no permitidos
function handle($data) { // ✗ Error: no type = mixed
    return $data;
}
```

**Recomendación:** Empieza en level 6, sube a 8-9 progresivamente.

---

## Configuración

### phpstan.neon (Básico)

```neon
parameters:
    level: 8
    paths:
        - src
        - tests
    excludePaths:
        - src/Legacy/*
        - tests/Fixtures/*

    # Symfony specific
    symfony:
        container_xml_path: var/cache/dev/App_KernelDevDebugContainer.xml

    # Doctrine specific
    doctrine:
        objectManagerLoader: tests/object-manager.php
```

### phpstan.neon (Avanzado)

```neon
includes:
    - phpstan-baseline.neon
    - vendor/phpstan/phpstan-symfony/extension.neon
    - vendor/phpstan/phpstan-doctrine/extension.neon
    - vendor/phpstan/phpstan-phpunit/extension.neon

parameters:
    level: 9

    paths:
        - src
        - tests

    excludePaths:
        - src/Kernel.php
        - tests/bootstrap.php

    # Ignores específicos
    ignoreErrors:
        - '#Call to an undefined method Symfony\\Component\\Config\\Definition\\Builder\\NodeDefinition::children\(\)#'
        -
            message: '#Access to an undefined property#'
            path: src/Legacy/*

    # Custom rules
    checkMissingIterableValueType: true
    checkGenericClassInNonGenericObjectType: true
    reportUnmatchedIgnoredErrors: true

    # Inferencia de tipos
    polluteScopeWithLoopInitialAssignments: false
    polluteScopeWithAlwaysIterableForeach: false

    # Bootstrap para constantes/funciones globales
    bootstrapFiles:
        - tests/bootstrap.php

    # Stubs para código sin types
    stubFiles:
        - stubs/legacy.stub
```

---

## Baseline Management

Para proyectos legacy, usa baseline para ignorar errores existentes:

### Crear Baseline

```bash
# Genera baseline con errores actuales
vendor/bin/phpstan analyse --generate-baseline

# Ahora solo nuevos errores fallarán
vendor/bin/phpstan analyse
```

**phpstan-baseline.neon** generado:
```neon
parameters:
    ignoreErrors:
        -
            message: '#Parameter \#1 \$user of method.*expects App\\Entity\\User, App\\Entity\\User\|null given#'
            count: 15
            path: src/Service/UserService.php
```

### Reducir Baseline Progresivamente

```bash
# 1. Fix algunos errores
# 2. Regenera baseline
vendor/bin/phpstan analyse --generate-baseline

# 3. Compara diferencias
git diff phpstan-baseline.neon

# 4. Commit solo si count bajó
```

**Objetivo:** Llegar a 0 errores en baseline, luego eliminarlo.

---

## Custom Rules

### Ejemplo: Prohibir `die()` y `exit()`

```php
// CustomRule.php
namespace App\PHPStan\Rules;

use PhpParser\Node;
use PHPStan\Analyser\Scope;
use PHPStan\Rules\Rule;

class NoDieOrExitRule implements Rule
{
    public function getNodeType(): string
    {
        return Node\Expr\Exit_::class;
    }

    public function processNode(Node $node, Scope $scope): array
    {
        return [
            'Using die() or exit() is not allowed. Use exceptions instead.'
        ];
    }
}
```

**phpstan.neon:**
```neon
services:
    -
        class: App\PHPStan\Rules\NoDieOrExitRule
        tags:
            - phpstan.rules.rule
```

---

## Integración CI/CD

### GitHub Actions

```yaml
name: PHPStan

on: [push, pull_request]

jobs:
  phpstan:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: 8.3
          coverage: none

      - name: Install dependencies
        run: composer install --prefer-dist --no-progress

      - name: Run PHPStan
        run: vendor/bin/phpstan analyse --error-format=github
```

### GitLab CI

```yaml
phpstan:
  stage: test
  image: php:8.3
  script:
    - composer install
    - vendor/bin/phpstan analyse --error-format=gitlab
  artifacts:
    reports:
      codequality: phpstan-report.json
```

---

## Extensiones Útiles

### PHPStan Symfony
```bash
composer require --dev phpstan/phpstan-symfony
```

**Detecta:**
- Servicios inexistentes del container
- Parámetros de configuración incorrectos
- Rutas inexistentes

### PHPStan Doctrine
```bash
composer require --dev phpstan/phpstan-doctrine
```

**Detecta:**
- Propiedades de entidades mal configuradas
- Queries DQL incorrectas
- Relaciones mal definidas

### PHPStan PHPUnit
```bash
composer require --dev phpstan/phpstan-phpunit
```

**Detecta:**
- Assertions incorrectas
- Mock methods inexistentes
- Test doubles mal configurados

### PHPStan Strict Rules
```bash
composer require --dev phpstan/phpstan-strict-rules
```

**Añade reglas extra:**
- No comparaciones loose (== vs ===)
- No casting implícito
- No short ternary (?:)

---

## Patrones Comunes

### Asserts para Narrow Types

```php
use Webmozart\Assert\Assert;

function processUser(?User $user): void
{
    Assert::notNull($user); // PHPStan entiende que $user ya no es null

    echo $user->getName(); // ✓ OK, no warning
}
```

### PHPDoc para Arrays Complejos

```php
/**
 * @param array<string, array{id: int, name: string, active: bool}> $users
 * @return array<int, string>
 */
function processUsers(array $users): array
{
    $result = [];
    foreach ($users as $key => $user) {
        // PHPStan sabe que $user['id'] es int
        // y que $user['name'] es string
        $result[$user['id']] = $user['name'];
    }
    return $result;
}
```

### Generics en Clases

```php
/**
 * @template T
 */
class Collection
{
    /** @var array<T> */
    private array $items = [];

    /** @param T $item */
    public function add($item): void
    {
        $this->items[] = $item;
    }

    /** @return array<T> */
    public function all(): array
    {
        return $this->items;
    }
}

// Uso
/** @var Collection<User> $users */
$users = new Collection();
$users->add(new User()); // ✓ OK
$users->add('string');   // ✗ Error: expects User
```

---

## Anti-Patterns

### ❌ Ignore Comments Excesivos

```php
// MAL: Ignorar en lugar de fixear
/** @phpstan-ignore-next-line */
$user->getName();
```

**MEJOR:**
```php
// Fix el problema real
if ($user !== null) {
    $user->getName();
}
```

### ❌ Baseline Gigante

```php
// MAL: Baseline con 500+ errores
// MEJOR: Fix progresivo, baseline temporal
```

### ❌ Level Bajo en Producción

```php
// MAL: level: 2
// MEJOR: level: 8+ progresivamente
```

---

## Errores Comunes

### 1. "Parameter has no value type"

```php
// Error
/** @param array $users */
function process(array $users) {}

// Fix
/** @param array<User> $users */
function process(array $users) {}
```

### 2. "Offset might not exist"

```php
// Error
$name = $data['name']; // $data es array

// Fix
$name = $data['name'] ?? 'default';
// o
if (isset($data['name'])) {
    $name = $data['name'];
}
```

### 3. "Negated boolean expression always false"

```php
// Error
if (!$user instanceof User) {
    return;
}
// PHPStan ya sabe que $user es User aquí
if (!$user instanceof User) { // Siempre false
    // ...
}

// Fix: Elimina el check redundante
```

---

## Performance Tips

```bash
# Caché resultante (más rápido en siguientes runs)
vendor/bin/phpstan analyse --memory-limit=1G

# Parallel processing (más rápido en máquinas multi-core)
vendor/bin/phpstan analyse --no-progress --parallel

# Solo archivos cambiados (para pre-commit hooks)
git diff --name-only --diff-filter=ACMRTUXB origin/main | \
  grep '\.php$' | \
  xargs vendor/bin/phpstan analyse
```

---

## 🔄 Auto-Mantenimiento con Context7

**Library tracked:** `/phpstan/phpstan`

**Actualización automática:**
```
mcp__context7__resolve-library-id: libraryName="PHPStan"
mcp__context7__query-docs: libraryId="/phpstan/phpstan", query="latest PHPStan features and rule changes"
```

**Qué se actualiza:**
- ✅ Nuevos niveles de análisis
- ✅ Nuevas reglas y checks
- ✅ Breaking changes entre versiones
- ✅ Nuevas extensiones disponibles
- ✅ Performance improvements

**Qué se preserva:**
- ✅ Nivel configurado (8-9 recomendado)
- ✅ Ignores personalizados
- ✅ Custom rules del proyecto
- ✅ Baseline strategy

**Frecuencia:** Automática cuando detecta nueva versión

**Última sync:** 2026-02-04
**Versión tracked:** 1.11.x

---

*Organismo viviente: Context7 + Experiencia comunitaria + Tu uso*
