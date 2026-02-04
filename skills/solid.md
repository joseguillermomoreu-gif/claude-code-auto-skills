# SOLID Principles - Principios de Diseño OOP

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Comunitario (teórico)

---

## Introducción

SOLID son 5 principios de diseño orientado a objetos que ayudan a crear código mantenible, escalable y flexible.

**Autor:** Robert C. Martin (Uncle Bob)

**Beneficios:**
- Código más fácil de entender
- Facilita testing
- Reduce acoplamiento
- Mejora reusabilidad
- Simplifica mantenimiento

---

## S - Single Responsibility Principle (SRP)

**"Una clase debe tener una sola razón para cambiar"**

### ❌ Violación

```php
class User
{
    public function __construct(
        private string $name,
        private string $email
    ) {}

    // ❌ Responsabilidad 1: Gestión de datos del usuario
    public function getName(): string
    {
        return $this->name;
    }

    // ❌ Responsabilidad 2: Validación
    public function isValidEmail(): bool
    {
        return filter_var($this->email, FILTER_VALIDATE_EMAIL) !== false;
    }

    // ❌ Responsabilidad 3: Persistencia
    public function save(PDO $db): void
    {
        $stmt = $db->prepare('INSERT INTO users (name, email) VALUES (?, ?)');
        $stmt->execute([$this->name, $this->email]);
    }

    // ❌ Responsabilidad 4: Notificaciones
    public function sendWelcomeEmail(): void
    {
        mail($this->email, 'Welcome', 'Welcome to our platform!');
    }
}
```

**Razones para cambiar:**
1. Cambio en estructura de datos del usuario
2. Cambio en reglas de validación
3. Cambio de base de datos
4. Cambio en sistema de emails

### ✅ Solución

```php
// Responsabilidad 1: Modelo de datos
class User
{
    public function __construct(
        private string $name,
        private Email $email // Value Object con su propia validación
    ) {}

    public function name(): string { return $this->name; }
    public function email(): Email { return $this->email; }
}

// Responsabilidad 2: Validación (dentro del Value Object)
final readonly class Email
{
    public function __construct(private string $value)
    {
        if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidEmailException();
        }
    }

    public function value(): string { return $this->value; }
}

// Responsabilidad 3: Persistencia
interface UserRepository
{
    public function save(User $user): void;
}

class DoctrineUserRepository implements UserRepository
{
    public function save(User $user): void
    {
        // Solo persistencia
    }
}

// Responsabilidad 4: Notificaciones
class UserNotifier
{
    public function __construct(private MailerInterface $mailer) {}

    public function sendWelcome(User $user): void
    {
        $this->mailer->send(
            new WelcomeEmail($user->email())
        );
    }
}
```

---

## O - Open/Closed Principle (OCP)

**"Abierto para extensión, cerrado para modificación"**

### ❌ Violación

```php
class PaymentProcessor
{
    public function process(string $type, float $amount): void
    {
        if ($type === 'credit_card') {
            // Procesar tarjeta
            $this->processCreditCard($amount);
        } elseif ($type === 'paypal') {
            // Procesar PayPal
            $this->processPayPal($amount);
        } elseif ($type === 'bitcoin') { // ❌ Modificando código existente
            // Procesar Bitcoin
            $this->processBitcoin($amount);
        }
        // ❌ Cada nuevo método de pago requiere modificar esta clase
    }
}
```

### ✅ Solución

```php
// Abstracción
interface PaymentMethod
{
    public function process(float $amount): void;
}

// Implementaciones concretas (extensión sin modificación)
class CreditCardPayment implements PaymentMethod
{
    public function process(float $amount): void
    {
        // Lógica específica de tarjeta
    }
}

class PayPalPayment implements PaymentMethod
{
    public function process(float $amount): void
    {
        // Lógica específica de PayPal
    }
}

// Nueva implementación SIN modificar código existente
class BitcoinPayment implements PaymentMethod
{
    public function process(float $amount): void
    {
        // Lógica específica de Bitcoin
    }
}

// Procesador genérico (cerrado para modificación)
class PaymentProcessor
{
    public function process(PaymentMethod $method, float $amount): void
    {
        $method->process($amount);
    }
}

// Uso
$processor = new PaymentProcessor();
$processor->process(new CreditCardPayment(), 100.00);
$processor->process(new BitcoinPayment(), 100.00); // ✅ Sin cambiar PaymentProcessor
```

---

## L - Liskov Substitution Principle (LSP)

**"Los subtipos deben ser sustituibles por sus tipos base"**

### ❌ Violación

```php
class Bird
{
    public function fly(): void
    {
        echo "Flying...";
    }
}

class Penguin extends Bird
{
    public function fly(): void
    {
        // ❌ Pingüino no puede volar, rompe el contrato
        throw new Exception("Penguins can't fly!");
    }
}

// Código que espera que todos los Bird puedan volar
function makeBirdFly(Bird $bird): void
{
    $bird->fly(); // ❌ Falla si es un Penguin
}

makeBirdFly(new Penguin()); // Exception!
```

### ✅ Solución

```php
// Abstracción más específica
interface Bird
{
    public function eat(): void;
    public function move(): void;
}

interface FlyingBird extends Bird
{
    public function fly(): void;
}

class Sparrow implements FlyingBird
{
    public function eat(): void { /* ... */ }
    public function move(): void { $this->fly(); }
    public function fly(): void { echo "Flying..."; }
}

class Penguin implements Bird
{
    public function eat(): void { /* ... */ }
    public function move(): void { $this->swim(); }
    public function swim(): void { echo "Swimming..."; }
}

// Funciones específicas para cada tipo
function makeFlyingBirdFly(FlyingBird $bird): void
{
    $bird->fly(); // ✅ Solo acepta aves que vuelan
}

function makeBirdMove(Bird $bird): void
{
    $bird->move(); // ✅ Todos los Bird pueden moverse (de alguna forma)
}
```

### Otro Ejemplo: Rectangle/Square

```php
// ❌ MAL
class Rectangle
{
    protected float $width;
    protected float $height;

    public function setWidth(float $width): void { $this->width = $width; }
    public function setHeight(float $height): void { $this->height = $height; }
    public function area(): float { return $this->width * $this->height; }
}

class Square extends Rectangle
{
    public function setWidth(float $width): void
    {
        // ❌ Rompe el contrato: cambiar width cambia también height
        $this->width = $width;
        $this->height = $width;
    }

    public function setHeight(float $height): void
    {
        $this->width = $height;
        $this->height = $height;
    }
}

function testRectangle(Rectangle $rect): void
{
    $rect->setWidth(5);
    $rect->setHeight(10);
    assert($rect->area() === 50); // ❌ Falla si es Square (área = 100)
}

// ✅ BIEN
interface Shape
{
    public function area(): float;
}

class Rectangle implements Shape
{
    public function __construct(
        private float $width,
        private float $height
    ) {}

    public function area(): float
    {
        return $this->width * $this->height;
    }
}

class Square implements Shape
{
    public function __construct(private float $side) {}

    public function area(): float
    {
        return $this->side * $this->side;
    }
}
```

---

## I - Interface Segregation Principle (ISP)

**"Los clientes no deben depender de interfaces que no usan"**

### ❌ Violación

```php
interface Worker
{
    public function work(): void;
    public function eat(): void;
    public function sleep(): void;
}

class HumanWorker implements Worker
{
    public function work(): void { /* ... */ }
    public function eat(): void { /* ... */ }
    public function sleep(): void { /* ... */ }
}

class RobotWorker implements Worker
{
    public function work(): void { /* ... */ }

    // ❌ Robot no come ni duerme
    public function eat(): void
    {
        throw new Exception("Robots don't eat");
    }

    public function sleep(): void
    {
        throw new Exception("Robots don't sleep");
    }
}
```

### ✅ Solución

```php
// Interfaces segregadas (específicas)
interface Workable
{
    public function work(): void;
}

interface Eatable
{
    public function eat(): void;
}

interface Sleepable
{
    public function sleep(): void;
}

// Implementaciones componen solo lo que necesitan
class HumanWorker implements Workable, Eatable, Sleepable
{
    public function work(): void { /* ... */ }
    public function eat(): void { /* ... */ }
    public function sleep(): void { /* ... */ }
}

class RobotWorker implements Workable
{
    public function work(): void { /* ... */ }
    // ✅ No necesita implementar eat() ni sleep()
}

// Uso
function makeWork(Workable $worker): void
{
    $worker->work(); // ✅ Funciona para cualquier Workable
}

function provideLunch(Eatable $worker): void
{
    $worker->eat(); // ✅ Solo para los que comen
}
```

---

## D - Dependency Inversion Principle (DIP)

**"Depender de abstracciones, no de concreciones"**

### ❌ Violación

```php
// Concreción de bajo nivel
class MySQLDatabase
{
    public function query(string $sql): array
    {
        // Query MySQL
        return [];
    }
}

// ❌ Alto nivel depende de bajo nivel (MySQL concreto)
class UserService
{
    private MySQLDatabase $db;

    public function __construct()
    {
        $this->db = new MySQLDatabase(); // ❌ Acoplamiento fuerte
    }

    public function getUsers(): array
    {
        return $this->db->query('SELECT * FROM users');
    }
}

// ❌ Imposible cambiar a PostgreSQL sin modificar UserService
```

### ✅ Solución

```php
// Abstracción (alto nivel define lo que necesita)
interface Database
{
    public function query(string $sql): array;
}

// Concreciones implementan la abstracción
class MySQLDatabase implements Database
{
    public function query(string $sql): array
    {
        // MySQL implementation
        return [];
    }
}

class PostgreSQLDatabase implements Database
{
    public function query(string $sql): array
    {
        // PostgreSQL implementation
        return [];
    }
}

// ✅ Alto nivel depende de abstracción
class UserService
{
    public function __construct(
        private Database $db // ✅ Inyección de dependencia
    ) {}

    public function getUsers(): array
    {
        return $this->db->query('SELECT * FROM users');
    }
}

// Uso (configurado externamente)
$db = new MySQLDatabase();
$service = new UserService($db);

// Fácil cambiar a PostgreSQL
$db = new PostgreSQLDatabase();
$service = new UserService($db); // ✅ Sin cambiar UserService
```

### Ejemplo Symfony

```yaml
# services.yaml
services:
    # Abstracción
    App\Domain\UserRepositoryInterface:
        # Implementación concreta
        class: App\Infrastructure\Persistence\DoctrineUserRepository

    # Service depende de abstracción
    App\Application\CreateUser\CreateUserHandler:
        arguments:
            - '@App\Domain\UserRepositoryInterface'
```

```php
// Service
class CreateUserHandler
{
    public function __construct(
        private UserRepositoryInterface $repository // ✅ Abstracción
    ) {}
}
```

---

## SOLID en la Práctica

### Checklist

**Single Responsibility:**
- [ ] ¿Esta clase hace solo una cosa?
- [ ] ¿Cuántas razones tiene para cambiar?
- [ ] ¿Puedo describir la clase en una frase sin "y"?

**Open/Closed:**
- [ ] ¿Puedo añadir funcionalidad sin modificar código existente?
- [ ] ¿Uso abstracciones (interfaces) en lugar de concretos?
- [ ] ¿Puedo extender comportamiento por herencia/composición?

**Liskov Substitution:**
- [ ] ¿Puedo sustituir clase base por derivada sin romper nada?
- [ ] ¿Las clases hijas respetan el contrato del padre?
- [ ] ¿Evito lanzar excepciones no esperadas en subclases?

**Interface Segregation:**
- [ ] ¿Mis interfaces son pequeñas y cohesivas?
- [ ] ¿Evito métodos que algunas implementaciones no usen?
- [ ] ¿Prefiero varias interfaces pequeñas a una grande?

**Dependency Inversion:**
- [ ] ¿Dependo de interfaces, no de clases concretas?
- [ ] ¿Inyecto dependencias en lugar de crearlas?
- [ ] ¿Mis abstracciones están en la capa de dominio?

---

## Anti-Patterns

### ❌ Sobre-ingeniería

```php
// ❌ YAGNI violation: interfaces para todo aunque solo haya 1 implementación
interface UserNameGetter
{
    public function getName(): string;
}

class User implements UserNameGetter
{
    public function getName(): string { return $this->name; }
}

// ✅ MEJOR: Solo crea abstracción cuando hay múltiples implementaciones
```

### ❌ God Objects

```php
// ❌ Clase que hace todo (viola SRP)
class Application
{
    public function handleRequest() {}
    public function connectDatabase() {}
    public function sendEmail() {}
    public function generatePDF() {}
    public function processPayment() {}
    // ... 50 métodos más
}
```

### ❌ Herencia profunda

```php
// ❌ Viola LSP si los hijos cambian comportamiento base
class A {}
class B extends A {}
class C extends B {}
class D extends C {}
class E extends D {} // ❌ Muy profundo, frágil

// ✅ MEJOR: Composición sobre herencia
class E
{
    public function __construct(
        private A $a,
        private B $b
    ) {}
}
```

---

## SOLID + Hexagonal Architecture

Combinar SOLID con arquitectura hexagonal:

```php
// SRP: Cada capa tiene una responsabilidad
Domain/      → Reglas de negocio
Application/ → Casos de uso
Infrastructure/ → Detalles técnicos

// OCP: Extensible con nuevos adaptadores
interface PaymentGateway {} // Puerto
class StripeAdapter implements PaymentGateway {} // Adaptador
class PayPalAdapter implements PaymentGateway {} // Nuevo sin modificar código

// LSP: Los adaptadores son intercambiables
function processPayment(PaymentGateway $gateway) {
    $gateway->process(); // Funciona con cualquier implementación
}

// ISP: Puertos pequeños y específicos
interface UserRepository { public function save(User $u): void; }
interface UserFinder { public function findById(int $id): ?User; }

// DIP: Dominio define puertos, infraestructura los implementa
Domain/UserRepository.php       → Interface (puerto)
Infrastructure/DoctrineUserRepository.php → Implementación (adaptador)
```

---

## 🔄 Auto-Mantenimiento

**Tipo:** Skill teórico/conceptual

**Actualización basada en:**
- ✅ Feedback de la comunidad
- ✅ Nuevos ejemplos y anti-patterns
- ✅ Tu experiencia de uso
- ✅ Evolución de mejores prácticas OOP

**Sin dependencia de framework específico**

**Última actualización:** 2026-02-04

---

*Mejora continua basada en experiencia de la comunidad*
