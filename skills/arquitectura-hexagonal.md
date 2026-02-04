# Arquitectura Hexagonal (Ports & Adapters)

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Comunitario (teórico)

---

## Introducción

La Arquitectura Hexagonal (también conocida como Ports & Adapters) es un patrón arquitectónico que separa la lógica de negocio de las dependencias externas (base de datos, frameworks, UI, etc.).

**Objetivo principal:** Hacer el dominio independiente de detalles técnicos.

**Beneficios:**
- Testeable sin infraestructura
- Cambiar DB/Framework sin tocar dominio
- Lógica de negocio aislada y clara
- Múltiples adaptadores para mismo puerto

**Autor:** Alistair Cockburn (2005)

---

## Conceptos Clave

### Hexágono (Dominio)

El centro de la aplicación. Contiene:
- **Entidades** (Domain models)
- **Value Objects**
- **Domain Services**
- **Domain Events**
- **Reglas de negocio**

**NO contiene:**
- Framework code (Symfony, Laravel, etc.)
- Database queries
- HTTP requests
- File system operations

### Puertos (Ports)

Interfaces que definen **qué** se puede hacer, no **cómo**.

**Tipos:**
1. **Puertos de entrada (Driving/Primary):** Use cases que la aplicación expone
2. **Puertos de salida (Driven/Secondary):** Servicios que la aplicación necesita

```php
// Puerto de entrada (lo que la app ofrece)
interface CreateUserUseCase
{
    public function execute(CreateUserCommand $command): User;
}

// Puerto de salida (lo que la app necesita)
interface UserRepository
{
    public function save(User $user): void;
    public function findById(UserId $id): ?User;
}
```

### Adaptadores (Adapters)

Implementaciones concretas de los puertos.

**Adaptadores de entrada (Primary):**
- HTTP Controllers
- CLI Commands
- Event Listeners
- GraphQL Resolvers

**Adaptadores de salida (Secondary):**
- Doctrine Repositories
- Email senders (Symfony Mailer)
- File storage (S3, local)
- External APIs

---

## Estructura de Carpetas

### Opción 1: Por Capas

```
src/
├── Domain/                    # ❤️ Corazón (sin dependencias externas)
│   ├── Model/
│   │   ├── User/
│   │   │   ├── User.php              # Entidad
│   │   │   ├── UserId.php            # Value Object
│   │   │   ├── Email.php             # Value Object
│   │   │   ├── UserRepository.php    # Puerto (interface)
│   │   │   └── UserCreated.php       # Domain Event
│   │   └── Order/
│   ├── Service/
│   │   └── UserDomainService.php     # Lógica de dominio compleja
│   └── Exception/
│       └── UserAlreadyExists.php
│
├── Application/               # 📋 Casos de uso
│   ├── CreateUser/
│   │   ├── CreateUserUseCase.php     # Puerto de entrada (interface)
│   │   ├── CreateUserCommand.php     # DTO
│   │   └── CreateUserHandler.php     # Implementación
│   └── GetUser/
│       ├── GetUserQuery.php
│       └── GetUserHandler.php
│
└── Infrastructure/            # 🔌 Adaptadores
    ├── Persistence/
    │   └── Doctrine/
    │       ├── DoctrineUserRepository.php  # Adaptador de salida
    │       └── Mapping/
    │           └── User.orm.xml
    ├── Http/
    │   └── Controller/
    │       └── CreateUserController.php    # Adaptador de entrada
    ├── Messaging/
    │   └── SymfonyEventDispatcher.php
    └── Email/
        └── SymfonyMailerAdapter.php
```

### Opción 2: Por Bounded Context

```
src/
├── User/
│   ├── Domain/
│   │   ├── User.php
│   │   ├── UserRepository.php
│   ├── Application/
│   │   └── CreateUser/
│   └── Infrastructure/
│       ├── Persistence/
│       └── Http/
│
└── Order/
    ├── Domain/
    ├── Application/
    └── Infrastructure/
```

---

## Ejemplo Completo: User Creation

### 1. Domain Layer

**User.php** (Entidad)
```php
namespace App\Domain\Model\User;

final class User
{
    private function __construct(
        private UserId $id,
        private Email $email,
        private HashedPassword $password,
        private Name $name
    ) {}

    public static function create(
        Email $email,
        PlainPassword $plainPassword,
        Name $name
    ): self {
        // Validaciones de dominio
        self::validatePasswordStrength($plainPassword);

        return new self(
            UserId::generate(),
            $email,
            HashedPassword::fromPlain($plainPassword),
            $name
        );
    }

    private static function validatePasswordStrength(PlainPassword $password): void
    {
        if (strlen($password->value()) < 8) {
            throw new WeakPasswordException();
        }
    }

    // Getters (sin setters públicos)
    public function id(): UserId { return $this->id; }
    public function email(): Email { return $this->email; }
    public function name(): Name { return $this->name; }

    // Comportamiento de dominio
    public function changeName(Name $newName): void
    {
        $this->name = $newName;
    }
}
```

**UserRepository.php** (Puerto)
```php
namespace App\Domain\Model\User;

interface UserRepository
{
    public function save(User $user): void;
    public function findById(UserId $id): ?User;
    public function findByEmail(Email $email): ?User;
    public function existsEmail(Email $email): bool;
}
```

**Value Objects:**
```php
namespace App\Domain\Model\User;

final readonly class Email
{
    private function __construct(private string $value)
    {
        if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidEmailException($value);
        }
    }

    public static function fromString(string $email): self
    {
        return new self($email);
    }

    public function value(): string
    {
        return $this->value;
    }

    public function equals(Email $other): bool
    {
        return $this->value === $other->value;
    }
}
```

### 2. Application Layer

**CreateUserCommand.php** (DTO)
```php
namespace App\Application\CreateUser;

final readonly class CreateUserCommand
{
    public function __construct(
        public string $email,
        public string $password,
        public string $name
    ) {}
}
```

**CreateUserUseCase.php** (Puerto de entrada)
```php
namespace App\Application\CreateUser;

use App\Domain\Model\User\User;

interface CreateUserUseCase
{
    public function execute(CreateUserCommand $command): User;
}
```

**CreateUserHandler.php** (Implementación del caso de uso)
```php
namespace App\Application\CreateUser;

use App\Domain\Model\User\{User, UserRepository, Email, PlainPassword, Name};
use App\Domain\Exception\UserAlreadyExistsException;

final readonly class CreateUserHandler implements CreateUserUseCase
{
    public function __construct(
        private UserRepository $userRepository
    ) {}

    public function execute(CreateUserCommand $command): User
    {
        $email = Email::fromString($command->email);

        // Regla de negocio: email único
        if ($this->userRepository->existsEmail($email)) {
            throw new UserAlreadyExistsException($email);
        }

        $user = User::create(
            $email,
            PlainPassword::fromString($command->password),
            Name::fromString($command->name)
        );

        $this->userRepository->save($user);

        return $user;
    }
}
```

### 3. Infrastructure Layer

**DoctrineUserRepository.php** (Adaptador)
```php
namespace App\Infrastructure\Persistence\Doctrine;

use App\Domain\Model\User\{User, UserRepository, UserId, Email};
use Doctrine\ORM\EntityManagerInterface;

final readonly class DoctrineUserRepository implements UserRepository
{
    public function __construct(
        private EntityManagerInterface $entityManager
    ) {}

    public function save(User $user): void
    {
        $this->entityManager->persist($user);
        $this->entityManager->flush();
    }

    public function findById(UserId $id): ?User
    {
        return $this->entityManager->find(User::class, $id->value());
    }

    public function findByEmail(Email $email): ?User
    {
        return $this->entityManager
            ->getRepository(User::class)
            ->findOneBy(['email.value' => $email->value()]);
    }

    public function existsEmail(Email $email): bool
    {
        return $this->findByEmail($email) !== null;
    }
}
```

**CreateUserController.php** (Adaptador HTTP)
```php
namespace App\Infrastructure\Http\Controller;

use App\Application\CreateUser\{CreateUserCommand, CreateUserUseCase};
use Symfony\Component\HttpFoundation\{Request, JsonResponse};

final readonly class CreateUserController
{
    public function __construct(
        private CreateUserUseCase $createUserUseCase
    ) {}

    public function __invoke(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        $command = new CreateUserCommand(
            email: $data['email'],
            password: $data['password'],
            name: $data['name']
        );

        try {
            $user = $this->createUserUseCase->execute($command);

            return new JsonResponse([
                'id' => $user->id()->value(),
                'email' => $user->email()->value(),
                'name' => $user->name()->value()
            ], 201);

        } catch (UserAlreadyExistsException $e) {
            return new JsonResponse(['error' => $e->getMessage()], 409);
        }
    }
}
```

---

## Inyección de Dependencias

**services.yaml:**
```yaml
services:
    # Application Services (Use Cases)
    App\Application\CreateUser\CreateUserUseCase:
        class: App\Application\CreateUser\CreateUserHandler
        arguments:
            - '@App\Domain\Model\User\UserRepository'

    # Repositories (Adaptadores)
    App\Domain\Model\User\UserRepository:
        class: App\Infrastructure\Persistence\Doctrine\DoctrineUserRepository
        arguments:
            - '@doctrine.orm.entity_manager'

    # Controllers (auto-wiring funciona)
    App\Infrastructure\Http\Controller\CreateUserController:
        tags: ['controller.service_arguments']
```

---

## Testing

### Unit Test (Dominio - sin dependencias)

```php
class UserTest extends TestCase
{
    public function test_user_can_be_created(): void
    {
        $user = User::create(
            Email::fromString('john@example.com'),
            PlainPassword::fromString('SecurePass123!'),
            Name::fromString('John Doe')
        );

        $this->assertInstanceOf(User::class, $user);
        $this->assertEquals('john@example.com', $user->email()->value());
    }

    public function test_weak_password_throws_exception(): void
    {
        $this->expectException(WeakPasswordException::class);

        User::create(
            Email::fromString('john@example.com'),
            PlainPassword::fromString('123'), // Too weak
            Name::fromString('John Doe')
        );
    }
}
```

### Integration Test (Application + Infrastructure)

```php
class CreateUserHandlerTest extends KernelTestCase
{
    private CreateUserUseCase $handler;
    private UserRepository $repository;

    protected function setUp(): void
    {
        self::bootKernel();
        $this->handler = self::getContainer()->get(CreateUserUseCase::class);
        $this->repository = self::getContainer()->get(UserRepository::class);
    }

    public function test_creates_user_successfully(): void
    {
        $command = new CreateUserCommand(
            email: 'john@example.com',
            password: 'SecurePass123!',
            name: 'John Doe'
        );

        $user = $this->handler->execute($command);

        $this->assertNotNull($user->id());
        $this->assertTrue($this->repository->existsEmail($user->email()));
    }

    public function test_throws_exception_if_email_already_exists(): void
    {
        // Create first user
        $this->handler->execute(new CreateUserCommand(
            email: 'john@example.com',
            password: 'Pass123!',
            name: 'John'
        ));

        // Try to create duplicate
        $this->expectException(UserAlreadyExistsException::class);

        $this->handler->execute(new CreateUserCommand(
            email: 'john@example.com', // Same email
            password: 'Pass456!',
            name: 'Another John'
        ));
    }
}
```

---

## Domain Events

```php
// Domain Event
final readonly class UserCreated
{
    public function __construct(
        public UserId $userId,
        public Email $email,
        public \DateTimeImmutable $occurredAt
    ) {}

    public static function now(UserId $userId, Email $email): self
    {
        return new self($userId, $email, new \DateTimeImmutable());
    }
}

// Modificar User::create()
public static function create(...): self
{
    $user = new self(...);

    // Grabar evento (no dispatchar aquí)
    $user->recordEvent(UserCreated::now($user->id(), $user->email()));

    return $user;
}

// Trait para eventos
trait RecordsEvents
{
    private array $events = [];

    protected function recordEvent(object $event): void
    {
        $this->events[] = $event;
    }

    public function releaseEvents(): array
    {
        $events = $this->events;
        $this->events = [];
        return $events;
    }
}

// En el Handler
public function execute(CreateUserCommand $command): User
{
    $user = User::create(...);
    $this->userRepository->save($user);

    // Dispatch events DESPUÉS de guardar
    foreach ($user->releaseEvents() as $event) {
        $this->eventDispatcher->dispatch($event);
    }

    return $user;
}
```

---

## Patrones Relacionados

### CQRS (Command Query Responsibility Segregation)

Separar comandos (escritura) de queries (lectura):

```php
// Command (modifica estado)
interface CreateUserUseCase
{
    public function execute(CreateUserCommand $command): void;
}

// Query (solo lectura)
interface GetUserQuery
{
    public function execute(GetUserQueryParams $params): UserDTO;
}
```

### Repository Pattern

Ya lo usamos en hexagonal. El repository ES el puerto de salida.

### Factory Pattern

Para creación compleja:

```php
interface UserFactory
{
    public function createFromRegistration(RegistrationData $data): User;
    public function createFromOAuth(OAuthData $data): User;
}
```

---

## Anti-Patterns

### ❌ Dominio acoplado a Framework

```php
// MAL: Entidad depende de Doctrine
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity]
class User
{
    #[ORM\Id, ORM\Column]
    private int $id;
}
```

**Mejor:** Mapeo externo (XML/YAML en Infrastructure)

### ❌ Use Cases llamando a otros Use Cases

```php
// MAL
class CreateOrderHandler
{
    public function execute(CreateOrderCommand $cmd): void
    {
        // ❌ Use Case llamando a otro Use Case
        $this->createUserUseCase->execute(...);
    }
}
```

**Mejor:** Extraer lógica común a Domain Service

### ❌ Anemic Domain Model

```php
// MAL: Solo getters/setters, sin comportamiento
class User
{
    public function setEmail(string $email): void { $this->email = $email; }
    public function getEmail(): string { return $this->email; }
}
```

**Mejor:** Comportamiento en el dominio

```php
class User
{
    public function changeEmail(Email $newEmail, EmailValidator $validator): void
    {
        $validator->ensureUnique($newEmail);
        $this->email = $newEmail;
        $this->recordEvent(EmailChanged::now($this->id, $newEmail));
    }
}
```

---

## Migración Progresiva

Si tienes código legacy:

1. **Empieza por un módulo pequeño** (ej: User)
2. **Crea el dominio sin tocar lo existente**
3. **Adaptadores que llaman al código legacy**
4. **Migra poco a poco** las features a hexagonal
5. **Tests primero** en el nuevo código

---

## 🔄 Auto-Mantenimiento

**Tipo:** Skill teórico/conceptual

**Actualización basada en:**
- ✅ Feedback de la comunidad
- ✅ Nuevos patterns descubiertos (DDD táctico)
- ✅ Tu experiencia de uso
- ✅ Evolución del estado del arte (Event Sourcing, CQRS+ES)

**Sin dependencia de framework específico**

**Última actualización:** 2026-02-04

---

*Mejora continua basada en experiencia de la comunidad*
