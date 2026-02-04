# PHP/Symfony - Arquitectura Hexagonal

> **Stack**: Symfony 7.x + PHP 8.3+
> **Arquitectura**: Hexagonal (Ports & Adapters)
> **Última actualización**: 2026-02-04

## Stack Tecnológico

- **Framework**: Symfony 7.x
- **PHP**: 8.3+ con strict types
- **ORM**: Doctrine
- **Testing**: PHPUnit + Behat
- **Quality**: PHPStan level 9

## Arquitectura Hexagonal

```
src/
├── Domain/              # Capa central (lógica de negocio)
│   ├── Entity/         # Entities de negocio
│   ├── ValueObject/    # Value Objects inmutables
│   ├── Repository/     # Interfaces de repositorios
│   ├── Service/        # Domain services
│   └── Exception/      # Excepciones de dominio
│
├── Application/         # Casos de uso
│   ├── UseCase/        # Use cases específicos
│   ├── DTO/            # Data Transfer Objects
│   └── Query/          # Queries (CQRS)
│
├── Infrastructure/      # Adaptadores (I/O)
│   ├── Persistence/    # Doctrine repositories
│   │   └── Doctrine/   # Implementaciones
│   ├── Controller/     # HTTP Controllers
│   ├── Command/        # CLI Commands
│   ├── EventListener/  # Event subscribers
│   └── External/       # APIs externas
│
└── Shared/             # Código compartido
    ├── Kernel.php
    └── Bus/            # Message bus
```

## Principios Fundamentales

### 1. Entities en Domain

```php
<?php
declare(strict_types=1);

namespace App\Domain\Entity;

use App\Domain\ValueObject\Email;
use App\Domain\ValueObject\UserId;

final class User
{
    private UserId $id;
    private Email $email;
    private \DateTimeImmutable $createdAt;

    private function __construct(
        UserId $id,
        Email $email
    ) {
        $this->id = $id;
        $this->email = $email;
        $this->createdAt = new \DateTimeImmutable();
    }

    public static function create(Email $email): self
    {
        return new self(
            UserId::generate(),
            $email
        );
    }

    public function changeEmail(Email $newEmail): void
    {
        // Validaciones de dominio aquí
        $this->email = $newEmail;
    }

    // Getters solo para lo necesario
    public function id(): UserId
    {
        return $this->id;
    }

    public function email(): Email
    {
        return $this->email;
    }
}
```

### 2. Value Objects Inmutables

```php
<?php
declare(strict_types=1);

namespace App\Domain\ValueObject;

final readonly class Email
{
    private function __construct(
        private string $value
    ) {
        $this->validate();
    }

    public static function fromString(string $email): self
    {
        return new self($email);
    }

    private function validate(): void
    {
        if (!filter_var($this->value, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException(
                "Invalid email: {$this->value}"
            );
        }
    }

    public function toString(): string
    {
        return $this->value;
    }

    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
}
```

### 3. Repository Interface en Domain

```php
<?php
declare(strict_types=1);

namespace App\Domain\Repository;

use App\Domain\Entity\User;
use App\Domain\ValueObject\Email;
use App\Domain\ValueObject\UserId;

interface UserRepositoryInterface
{
    public function save(User $user): void;

    public function findById(UserId $id): ?User;

    public function findByEmail(Email $email): ?User;

    public function remove(User $user): void;
}
```

### 4. Implementación en Infrastructure

```php
<?php
declare(strict_types=1);

namespace App\Infrastructure\Persistence\Doctrine;

use App\Domain\Entity\User;
use App\Domain\Repository\UserRepositoryInterface;
use App\Domain\ValueObject\Email;
use App\Domain\ValueObject\UserId;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

final class DoctrineUserRepository extends ServiceEntityRepository implements UserRepositoryInterface
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, User::class);
    }

    public function save(User $user): void
    {
        $this->getEntityManager()->persist($user);
        $this->getEntityManager()->flush();
    }

    public function findById(UserId $id): ?User
    {
        return $this->find($id->toString());
    }

    public function findByEmail(Email $email): ?User
    {
        return $this->findOneBy(['email' => $email->toString()]);
    }

    public function remove(User $user): void
    {
        $this->getEntityManager()->remove($user);
        $this->getEntityManager()->flush();
    }
}
```

### 5. Use Case en Application

```php
<?php
declare(strict_types=1);

namespace App\Application\UseCase;

use App\Application\DTO\CreateUserDTO;
use App\Domain\Entity\User;
use App\Domain\Repository\UserRepositoryInterface;
use App\Domain\ValueObject\Email;

final readonly class CreateUserUseCase
{
    public function __construct(
        private UserRepositoryInterface $userRepository
    ) {}

    public function execute(CreateUserDTO $dto): User
    {
        $email = Email::fromString($dto->email);

        // Validación de negocio
        if ($this->userRepository->findByEmail($email)) {
            throw new \DomainException('User already exists');
        }

        $user = User::create($email);
        $this->userRepository->save($user);

        return $user;
    }
}
```

### 6. Controller en Infrastructure

```php
<?php
declare(strict_types=1);

namespace App\Infrastructure\Controller;

use App\Application\DTO\CreateUserDTO;
use App\Application\UseCase\CreateUserUseCase;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class UserController extends AbstractController
{
    public function __construct(
        private readonly CreateUserUseCase $createUser
    ) {}

    #[Route('/api/users', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $dto = new CreateUserDTO(
            email: $request->request->get('email')
        );

        try {
            $user = $this->createUser->execute($dto);

            return new JsonResponse([
                'id' => $user->id()->toString(),
                'email' => $user->email()->toString(),
            ], Response::HTTP_CREATED);

        } catch (\DomainException $e) {
            return new JsonResponse([
                'error' => $e->getMessage()
            ], Response::HTTP_BAD_REQUEST);
        }
    }
}
```

## Testing

### Unit Test (Domain)

```php
<?php
declare(strict_types=1);

namespace Tests\Unit\Domain\Entity;

use App\Domain\Entity\User;
use App\Domain\ValueObject\Email;
use PHPUnit\Framework\TestCase;

final class UserTest extends TestCase
{
    public function test_creates_user_with_valid_email(): void
    {
        // Arrange
        $email = Email::fromString('test@example.com');

        // Act
        $user = User::create($email);

        // Assert
        $this->assertEquals($email, $user->email());
        $this->assertInstanceOf(\DateTimeImmutable::class, $user->createdAt());
    }

    public function test_changes_email(): void
    {
        // Arrange
        $user = User::create(Email::fromString('old@example.com'));
        $newEmail = Email::fromString('new@example.com');

        // Act
        $user->changeEmail($newEmail);

        // Assert
        $this->assertEquals($newEmail, $user->email());
    }
}
```

### Integration Test (Use Case)

```php
<?php
declare(strict_types=1);

namespace Tests\Integration\Application\UseCase;

use App\Application\DTO\CreateUserDTO;
use App\Application\UseCase\CreateUserUseCase;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

final class CreateUserUseCaseTest extends KernelTestCase
{
    private CreateUserUseCase $useCase;

    protected function setUp(): void
    {
        self::bootKernel();
        $this->useCase = self::getContainer()->get(CreateUserUseCase::class);
    }

    public function test_creates_user_successfully(): void
    {
        // Arrange
        $dto = new CreateUserDTO(email: 'test@example.com');

        // Act
        $user = $this->useCase->execute($dto);

        // Assert
        $this->assertNotNull($user->id());
        $this->assertEquals('test@example.com', $user->email()->toString());
    }
}
```

## Convenciones

### Naming

- **Entities**: Sustantivos singulares (`User`, `Order`)
- **Value Objects**: Sustantivos descriptivos (`Email`, `Money`)
- **Use Cases**: Verbo + sustantivo + UseCase (`CreateUserUseCase`)
- **Repositories**: Sustantivo + Repository (`UserRepository`)
- **DTOs**: Sustantivo + DTO (`CreateUserDTO`)

### Type Safety

```php
<?php
declare(strict_types=1);  // SIEMPRE en la primera línea

// Type hints en todo
public function process(int $id, string $name): User
{
    // ...
}

// Propiedades tipadas
private readonly UserRepository $repository;

// Readonly cuando sea posible (PHP 8.1+)
final readonly class CreateUserDTO
{
    public function __construct(
        public string $email,
    ) {}
}
```

## Comandos Útiles

```bash
# Tests
vendor/bin/phpunit
vendor/bin/behat

# Quality
vendor/bin/phpstan analyze
vendor/bin/php-cs-fixer fix

# Doctrine
bin/console doctrine:migrations:migrate
bin/console doctrine:schema:validate

# Cache
bin/console cache:clear
```

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- Detectes uso de Symfony 8.x o versiones nuevas
- Encuentres mejores patrones de arquitectura hexagonal
- Veas nuevas features de PHP 8.4+
- Identifiques anti-patterns en mi código

**Preserva siempre**:
- Principios de arquitectura hexagonal
- Estructura de directorios
- Convenciones de naming
- Type safety estricto

**Usa Context7**:
```php
resolve-library-id: "symfony/symfony"
query-docs: "latest Symfony features 2026"
```
