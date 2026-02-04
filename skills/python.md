# Python para Developers PHP/Symfony

> **Audiencia**: Desarrolladores PHP senior aprendiendo Python
> **Última actualización**: 2026-02-04
> **Python version**: 3.12+

## Mindset Shift: PHP → Python

### Conceptos Equivalentes

| PHP/Symfony | Python | Diferencia clave |
|-------------|--------|------------------|
| `composer.json` | `pyproject.toml` + `poetry.lock` | Poetry = Composer moderno |
| `interface` | `Protocol` / `ABC` | Protocols más flexibles (duck typing) |
| `namespace` | `package` (directorios) | Imports relativos vs absolutos |
| `trait` | Mixins | Similar, pero cuidado con MRO |
| `__construct()` | `__init__()` | Mismo concepto |
| `private` | `_private` | Convención, no enforcement |
| `$this->` | `self.` | Sin signo $ |

### Type Hints: Lo que ya sabes

```python
# Esto te resultará familiar:
def process_order(order_id: int, user_id: str) -> OrderDTO:
    pass

# Equivalente a PHP 8:
# function processOrder(int $orderId, string $userId): OrderDTO
```

**Diferencias importantes**:
- Python: `list[str]` vs PHP: `array<string>`
- Python: `dict[str, int]` vs PHP: `array<string, int>`
- Python: `Optional[str]` vs PHP: `?string`
- Python: `Union[int, str]` vs PHP: `int|string`

### Error Handling: Try/Except vs Try/Catch

```python
# Python (preferido)
from typing import Optional

def find_user(user_id: int) -> Optional[User]:
    try:
        return db.query(User).get(user_id)
    except EntityNotFound:
        return None  # Explícito > lanzar excepción

# PHP equivalente:
# public function findUser(int $userId): ?User
```

## Dependency Injection: Sin Symfony

**En PHP/Symfony**:
```php
// services.yaml hace la magia
public function __construct(
    private UserRepository $userRepo,
    private LoggerInterface $logger
) {}
```

**En Python (patrón recomendado)**:
```python
# Usa dataclasses + dependency-injector o manual
from dataclasses import dataclass

@dataclass
class OrderService:
    user_repo: UserRepository
    logger: Logger

    def process(self, order_id: int) -> None:
        # Usa self.user_repo, self.logger
        pass

# Instanciación manual (más explícito que Symfony):
service = OrderService(
    user_repo=UserRepository(db),
    logger=setup_logger()
)
```

## Gestión de Dependencias

```bash
# Composer → Poetry
composer install          → poetry install
composer require package  → poetry add package
composer require --dev    → poetry add --group dev
composer.json             → pyproject.toml
composer.lock             → poetry.lock

# Symfony console → Python CLI
bin/console               → python -m src.cli
```

## Estructura de Proyecto Python

```
my_project/
├── src/
│   ├── __init__.py          # Marca como package
│   ├── domain/              # Como tu capa Domain en Symfony
│   ├── application/         # Use cases
│   └── infrastructure/      # Adaptadores
├── tests/
│   ├── __init__.py
│   └── test_*.py            # Prefijo test_ obligatorio
├── pyproject.toml           # composer.json
├── poetry.lock              # composer.lock
└── README.md
```

## Convenciones PEP 8 (vs PSR-12)

```python
# Naming (diferente a PHP PSR-12)
class UserService:          # PascalCase (igual que PHP)
    def process_order():    # snake_case (vs camelCase PHP)
        user_id = 123       # snake_case (vs $camelCase PHP)
        MAX_RETRIES = 3     # UPPER_SNAKE (igual que PHP)
```

## Testing: PHPUnit → Pytest

```python
# test_user_service.py
import pytest
from src.services import UserService

class TestUserService:  # Clase opcional (vs obligatoria en PHPUnit)

    def test_creates_user_successfully(self):  # test_ prefix obligatorio
        # Arrange
        service = UserService()

        # Act
        result = service.create_user("john@example.com")

        # Assert
        assert result.email == "john@example.com"
        assert result.id is not None

# Fixtures (equivalente a setUp en PHPUnit)
@pytest.fixture
def user_service():
    return UserService(repo=MockUserRepo())

def test_with_fixture(user_service):
    result = user_service.find_user(1)
    assert result is not None
```

## Recursos Rápidos

- **Documentación**: Usa Context7 para queries específicas
- **Type checking**: `mypy src/` (equivalente a PHPStan/Psalm)
- **Linting**: `ruff check` (más rápido que PHP-CS-Fixer)
- **Testing**: `pytest -v`

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza este archivo cuando**:
- Detectes que estoy usando una versión nueva de Python
- Encuentres mejores equivalencias PHP → Python
- Descubras patrones que me cuestan entender
- Identifiques errores recurrentes que cometo

**Preserva siempre**:
- Ejemplos comparativos PHP/Symfony
- Estructura de secciones
- Referencias a mi stack (Symfony, arquitectura hexagonal)

**Usa Context7**:
```python
# Cuando necesites actualizar info de librerías específicas
resolve-library-id: "python" o librería específica
query-docs: "latest features Python 3.12" o similar
```
