# Clean Code - Código Limpio y Mantenible

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Comunitario (teórico)

---

## Introducción

Clean Code son principios y prácticas para escribir código legible, mantenible y profesional.

**Autor:** Robert C. Martin (Uncle Bob)

**Objetivo:** Código que otros (y tú en 6 meses) puedan entender fácilmente.

---

## Naming (Nombres)

### Variables y Propiedades

```php
// ❌ MAL
$d = 86400; // ¿Qué es d?
$temp = getUser(); // ¿temp de qué?
$flag = true; // ¿Qué flag?
$data = []; // ¿Qué datos?

// ✅ BIEN
$secondsInDay = 86400;
$authenticatedUser = getUser();
$isEmailVerified = true;
$productPrices = [];
```

**Reglas:**
- Nombres descriptivos y pronunciables
- Evita abreviaturas (`usr` → `user`)
- Usa nombres buscables (no `e`, `a`, `n`)
- Un concepto = una palabra (`get`, no mezclar con `fetch`, `retrieve`)

### Funciones y Métodos

```php
// ❌ MAL
function proc($u) {} // ¿Qué procesa?
function data() {} // Verbo, no sustantivo
function getUserDataAndCheckPermissionsAndSendEmail() {} // Hace demasiado

// ✅ BIEN
function processUserRegistration(User $user): void {}
function calculateTotalPrice(array $items): float {}
function isEligibleForDiscount(User $user): bool {}
```

**Convenciones:**
- Verbos para acciones: `save`, `delete`, `calculate`, `validate`
- Predicados booleanos: `is`, `has`, `can`, `should`
- Getters: `get` o sin prefijo en PHP 8.1+
- Setters: `set` o constructor immutable

### Clases

```php
// ❌ MAL
class Manager {} // ¿Qué gestiona?
class Data {} // Muy genérico
class Helper {} // Sin significado
class Utils {} // Cajón de sastre

// ✅ BIEN
class UserRegistrationService {}
class PriceCalculator {}
class EmailValidator {}
class OrderRepository {}
```

**Patrones:**
- Sustantivos o frases nominales
- Service: `*Service`
- Repository: `*Repository`
- Factory: `*Factory`
- Value Objects: nombre del concepto (`Email`, `Money`)

### Constantes

```php
// ❌ MAL
const MAX = 100; // ¿Max de qué?
const LIMIT = 50;

// ✅ BIEN
const MAX_LOGIN_ATTEMPTS = 5;
const SESSION_TIMEOUT_MINUTES = 30;
const DEFAULT_PAGE_SIZE = 20;
```

---

## Functions (Funciones)

### Small (Pequeñas)

```php
// ❌ MAL: Función de 50 líneas
function processOrder(Order $order): void
{
    // Validar
    if (!$order->hasItems()) { throw new Exception(); }
    if ($order->total() <= 0) { throw new Exception(); }

    // Calcular impuestos
    $tax = 0;
    foreach ($order->items() as $item) {
        $tax += $item->price() * 0.21;
    }
    $order->setTax($tax);

    // Aplicar descuentos
    // ... 20 líneas más ...

    // Guardar
    $this->repository->save($order);

    // Enviar email
    // ... 10 líneas más ...
}

// ✅ BIEN: Función pequeña, delegando responsabilidades
function processOrder(Order $order): void
{
    $this->validateOrder($order);
    $this->applyTaxes($order);
    $this->applyDiscounts($order);
    $this->saveOrder($order);
    $this->notifyCustomer($order);
}
```

**Reglas:**
- Máximo 20 líneas (ideal: 5-10)
- Un nivel de abstracción por función
- Hacer una cosa, hacerla bien

### Do One Thing

```php
// ❌ MAL: Hace múltiples cosas
function getUserAndSendEmail(int $userId): void
{
    $user = $this->repository->find($userId);

    if ($user->isActive()) {
        $email = new WelcomeEmail($user);
        $this->mailer->send($email);
    }

    $this->logger->info("User processed: {$userId}");
}

// ✅ BIEN: Una responsabilidad por función
function sendWelcomeEmail(int $userId): void
{
    $user = $this->getActiveUser($userId);

    if ($user === null) {
        return;
    }

    $this->sendEmail($user);
    $this->logEmailSent($userId);
}

private function getActiveUser(int $userId): ?User
{
    $user = $this->repository->find($userId);
    return $user?->isActive() ? $user : null;
}

private function sendEmail(User $user): void
{
    $this->mailer->send(new WelcomeEmail($user));
}

private function logEmailSent(int $userId): void
{
    $this->logger->info("Welcome email sent to user: {$userId}");
}
```

### Pocos Argumentos

```php
// ❌ MAL: Demasiados parámetros
function createUser(
    string $name,
    string $email,
    string $password,
    string $phone,
    string $address,
    string $city,
    string $country
): User {
    // ...
}

// ✅ BIEN: Objeto de parámetros (DTO)
function createUser(CreateUserData $data): User
{
    // ...
}

readonly class CreateUserData
{
    public function __construct(
        public string $name,
        public string $email,
        public string $password,
        public string $phone,
        public string $address,
        public string $city,
        public string $country
    ) {}
}
```

**Ideal:**
- 0 argumentos (niladic) → Perfecto
- 1 argumento (monadic) → Muy bien
- 2 argumentos (dyadic) → Bien
- 3+ argumentos → Considerar objeto de parámetros

### Sin Side Effects

```php
// ❌ MAL: Side effect oculto
function checkPassword(string $password): bool
{
    if ($this->passwordHasher->verify($password)) {
        $this->session->initialize(); // ❌ Side effect no esperado
        return true;
    }
    return false;
}

// ✅ BIEN: Explícito
function isPasswordCorrect(string $password): bool
{
    return $this->passwordHasher->verify($password);
}

function login(string $username, string $password): void
{
    if ($this->isPasswordCorrect($password)) {
        $this->session->initialize(); // ✅ Explícito
    }
}
```

---

## Comments (Comentarios)

### Buenos Comentarios

```php
// ✅ BIEN: Explicar "por qué", no "qué"

// Workaround: PHP bug #12345 - strtotime fails with this format
$date = DateTime::createFromFormat('Y-m-d', $dateString);

// TODO: Refactor to use Strategy pattern when we add more payment methods
public function processPayment(string $type): void {}

/**
 * RFC 3986 compliant URL encoding
 * @see https://www.ietf.org/rfc/rfc3986.txt
 */
public function encodeUrl(string $url): string {}

// IMPORTANT: This must be called BEFORE saveOrder() to avoid race conditions
public function reserveStock(Order $order): void {}
```

### Malos Comentarios

```php
// ❌ MAL: Obviedades

// Get the user
$user = $this->userRepository->find($id);

// Loop through items
foreach ($items as $item) {
    // Process item
    $this->processItem($item);
}

// Constructor
public function __construct() {}

// i++
$i++;

// ❌ MAL: Comentario desactualizado
// Returns User or null if not found
public function getUser(int $id): User // ❌ Ya no devuelve null, lanza exception
{
    return $this->repository->findOrFail($id);
}
```

**Regla de oro:** El código debe auto-explicarse. Comenta solo cuando el código no pueda expresar la intención.

---

## Formatting (Formato)

### Vertical (Líneas)

```php
// ✅ BIEN: Líneas en blanco separan conceptos

class UserService
{
    private UserRepository $repository;
    private PasswordHasher $hasher;

    public function __construct(
        UserRepository $repository,
        PasswordHasher $hasher
    ) {
        $this->repository = $repository;
        $this->hasher = $hasher;
    }

    public function register(string $email, string $password): User
    {
        $this->validateEmail($email);
        $this->validatePassword($password);

        $user = new User($email, $this->hasher->hash($password));

        $this->repository->save($user);

        return $user;
    }
}
```

**Reglas:**
- Línea en blanco entre métodos
- Línea en blanco entre grupos lógicos dentro de métodos
- Variables relacionadas juntas
- Máximo 100-120 caracteres por línea

### Horizontal (Indentación)

```php
// ❌ MAL
if($user->isActive()){$this->activate();$user->notify();}

// ✅ BIEN
if ($user->isActive()) {
    $this->activate();
    $user->notify();
}

// ✅ BIEN: Alineación de asignaciones (opcional)
$firstName = $data['first_name'];
$lastName  = $data['last_name'];
$email     = $data['email'];
```

---

## Error Handling (Manejo de Errores)

### Excepciones vs Códigos de Error

```php
// ❌ MAL: Códigos de error
function deleteUser(int $id): int
{
    if (!$this->exists($id)) {
        return -1; // ❌ Código de error
    }

    if (!$this->hasPermission()) {
        return -2;
    }

    $this->repository->delete($id);
    return 0; // Success
}

$result = $this->deleteUser(123);
if ($result === -1) { /* ... */ }
elseif ($result === -2) { /* ... */ }

// ✅ BIEN: Excepciones
function deleteUser(int $id): void
{
    $user = $this->repository->findOrFail($id); // Lanza UserNotFoundException

    if (!$this->hasPermission()) {
        throw new InsufficientPermissionsException();
    }

    $this->repository->delete($user);
}

try {
    $this->deleteUser(123);
} catch (UserNotFoundException $e) {
    // Handle not found
} catch (InsufficientPermissionsException $e) {
    // Handle permission denied
}
```

### Excepciones Específicas

```php
// ❌ MAL: Excepciones genéricas
throw new Exception("Invalid email");
throw new RuntimeException("User not found");

// ✅ BIEN: Excepciones de dominio
throw new InvalidEmailException($email);
throw new UserNotFoundException($userId);
throw new InsufficientStockException($product, $requestedQuantity);
```

### Don't Return Null

```php
// ❌ MAL
public function findUser(int $id): ?User
{
    return $this->repository->find($id); // Puede ser null
}

$user = $this->findUser(123);
$name = $user->getName(); // ❌ Posible null pointer

// ✅ BIEN: Null Object Pattern
public function findUser(int $id): User
{
    return $this->repository->find($id) ?? new NullUser();
}

class NullUser extends User
{
    public function getName(): string { return 'Guest'; }
    public function isNull(): bool { return true; }
}

// ✅ BIEN: Lanzar excepción
public function getUser(int $id): User
{
    $user = $this->repository->find($id);

    if ($user === null) {
        throw new UserNotFoundException($id);
    }

    return $user;
}
```

---

## DRY (Don't Repeat Yourself)

```php
// ❌ MAL: Código duplicado
public function formatUserData(User $user): array
{
    return [
        'id' => $user->getId(),
        'name' => $user->getName(),
        'email' => $user->getEmail(),
        'created_at' => $user->getCreatedAt()->format('Y-m-d H:i:s')
    ];
}

public function formatAdminData(Admin $admin): array
{
    return [
        'id' => $admin->getId(),
        'name' => $admin->getName(),
        'email' => $admin->getEmail(),
        'created_at' => $admin->getCreatedAt()->format('Y-m-d H:i:s'),
        'role' => 'admin'
    ];
}

// ✅ BIEN: Extraer lógica común
private function formatBaseData(User $user): array
{
    return [
        'id' => $user->getId(),
        'name' => $user->getName(),
        'email' => $user->getEmail(),
        'created_at' => $user->getCreatedAt()->format('Y-m-d H:i:s')
    ];
}

public function formatUserData(User $user): array
{
    return $this->formatBaseData($user);
}

public function formatAdminData(Admin $admin): array
{
    return array_merge($this->formatBaseData($admin), [
        'role' => 'admin'
    ]);
}
```

---

## KISS (Keep It Simple, Stupid)

```php
// ❌ MAL: Sobre-complicado
public function isEligible(User $user): bool
{
    return ($user->getAge() >= 18
        && ($user->hasVerifiedEmail() === true || $user->hasVerifiedPhone() === true)
        && (($user->getCountry() === 'ES' || $user->getCountry() === 'FR')
            || ($user->getCountry() === 'DE' && $user->getState() !== 'BY'))
    ) ? true : false;
}

// ✅ BIEN: Simple y claro
public function isEligible(User $user): bool
{
    if ($user->getAge() < 18) {
        return false;
    }

    if (!$user->hasVerifiedContact()) {
        return false;
    }

    return $this->isFromEligibleCountry($user);
}

private function hasVerifiedContact(): bool
{
    return $this->hasVerifiedEmail() || $this->hasVerifiedPhone();
}

private function isFromEligibleCountry(User $user): bool
{
    $allowedCountries = ['ES', 'FR'];

    if (in_array($user->getCountry(), $allowedCountries)) {
        return true;
    }

    return $user->getCountry() === 'DE' && $user->getState() !== 'BY';
}
```

---

## YAGNI (You Aren't Gonna Need It)

```php
// ❌ MAL: Código "por si acaso"
class User
{
    private string $name;
    private string $email;

    // ❌ Nadie lo usa todavía, "por si acaso en el futuro"
    private ?string $middleName = null;
    private ?string $nickname = null;
    private ?array $preferences = null;
    private ?array $metadata = null;

    // ❌ Método genérico "por si acaso"
    public function setCustomAttribute(string $key, mixed $value): void {}
    public function getCustomAttribute(string $key): mixed {}
}

// ✅ BIEN: Solo lo que necesitas AHORA
class User
{
    public function __construct(
        private string $name,
        private string $email
    ) {}

    // Añade middleName, nickname, etc. CUANDO los necesites
}
```

---

## Boy Scout Rule

**"Deja el código más limpio de como lo encontraste"**

```php
// Encontraste esto:
public function calculateTotal($items) {
    $t=0;
    for($i=0;$i<count($items);$i++){
        $t+=$items[$i]['price']*$items[$i]['qty'];
    }
    return $t;
}

// Déjalo así (pequeñas mejoras):
public function calculateTotal(array $items): float
{
    $total = 0.0;

    foreach ($items as $item) {
        $total += $item['price'] * $item['quantity'];
    }

    return $total;
}

// O mejor aún:
public function calculateTotal(array $items): Money
{
    return array_reduce(
        $items,
        fn(Money $total, Item $item) => $total->add($item->subtotal()),
        Money::zero()
    );
}
```

---

## 🔄 Auto-Mantenimiento

**Tipo:** Skill teórico/conceptual

**Actualización basada en:**
- ✅ Feedback de la comunidad
- ✅ Nuevos patterns y anti-patterns
- ✅ Tu experiencia de uso
- ✅ Evolución de mejores prácticas

**Sin dependencia de framework específico**

**Última actualización:** 2026-02-04

---

*Mejora continua basada en experiencia de la comunidad*
