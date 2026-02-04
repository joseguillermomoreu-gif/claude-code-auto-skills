# TypeScript - Convenciones y Patterns

> **Versión**: TypeScript 5.x
> **Última actualización**: 2026-02-04

## Configuración Base (tsconfig.json)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022", "DOM"],
    "moduleResolution": "bundler",
    "strict": true,
    "strictNullChecks": true,
    "noImplicitAny": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  }
}
```

## Naming Conventions

```typescript
// Interfaces: PascalCase (sin prefijo I)
interface User {
  id: string;
  email: string;
}

// Types: PascalCase
type UserId = string;
type UserRole = 'admin' | 'user' | 'guest';

// Enums: PascalCase (keys y enum name)
enum OrderStatus {
  Pending = 'pending',
  Shipped = 'shipped',
  Delivered = 'delivered'
}

// Classes: PascalCase
class UserService {
  // Propiedades privadas: camelCase con _
  private _repository: UserRepository;

  // Métodos: camelCase
  public async createUser(email: string): Promise<User> {
    // ...
  }
}

// Funciones: camelCase
function calculateTotal(items: Item[]): number {
  // ...
}

// Constantes: UPPER_SNAKE_CASE
const MAX_RETRIES = 3;
const API_BASE_URL = 'https://api.example.com';

// Variables: camelCase
const userName = 'John';
let isActive = true;
```

## Types vs Interfaces

### Cuándo usar Interfaces

```typescript
// Para objetos y contratos
interface User {
  id: string;
  name: string;
  email: string;
}

// Cuando necesitas extends
interface Admin extends User {
  permissions: string[];
}

// Cuando necesitas declaration merging
interface Window {
  myCustomProperty: string;
}
```

### Cuándo usar Types

```typescript
// Para unions
type Result = Success | Error;
type Status = 'pending' | 'success' | 'error';

// Para intersections
type AdminUser = User & { permissions: string[] };

// Para tipos complejos
type AsyncFunction<T> = () => Promise<T>;

// Para mapped types
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};
```

## Utility Types

```typescript
// Partial: Hace todas las propiedades opcionales
interface User {
  id: string;
  name: string;
  email: string;
}

type PartialUser = Partial<User>;
// { id?: string; name?: string; email?: string; }

// Required: Hace todas las propiedades requeridas
type RequiredUser = Required<PartialUser>;

// Pick: Selecciona propiedades específicas
type UserPreview = Pick<User, 'id' | 'name'>;
// { id: string; name: string; }

// Omit: Excluye propiedades
type UserWithoutId = Omit<User, 'id'>;
// { name: string; email: string; }

// Record: Objeto con keys y valores específicos
type UserRoles = Record<string, 'admin' | 'user'>;
// { [key: string]: 'admin' | 'user' }

// ReturnType: Extrae tipo de retorno de función
function getUser() {
  return { id: '1', name: 'John' };
}
type User = ReturnType<typeof getUser>;
```

## Type Guards

```typescript
// Type predicate
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

// Uso
function process(value: string | number) {
  if (isString(value)) {
    // TypeScript sabe que value es string aquí
    console.log(value.toUpperCase());
  } else {
    // Y number aquí
    console.log(value.toFixed(2));
  }
}

// Type guard con discriminated unions
interface Success {
  type: 'success';
  data: string;
}

interface Error {
  type: 'error';
  message: string;
}

type Result = Success | Error;

function handleResult(result: Result) {
  if (result.type === 'success') {
    // TypeScript sabe que result es Success
    console.log(result.data);
  } else {
    // Y Error aquí
    console.log(result.message);
  }
}
```

## Generics

```typescript
// Función genérica básica
function identity<T>(value: T): T {
  return value;
}

// Generic con constraint
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Clase genérica
class Repository<T> {
  private items: T[] = [];

  add(item: T): void {
    this.items.push(item);
  }

  getAll(): T[] {
    return this.items;
  }
}

// Uso
const userRepo = new Repository<User>();
userRepo.add({ id: '1', name: 'John', email: 'john@example.com' });

// Generic con múltiples type parameters
function map<T, U>(
  array: T[],
  fn: (item: T) => U
): U[] {
  return array.map(fn);
}
```

## Async/Await y Promises

```typescript
// Función async siempre retorna Promise
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);

  if (!response.ok) {
    throw new Error('User not found');
  }

  return response.json();
}

// Manejo de errores
async function getUserSafely(id: string): Promise<User | null> {
  try {
    return await fetchUser(id);
  } catch (error) {
    console.error('Error fetching user:', error);
    return null;
  }
}

// Promise.all con types
async function fetchMultipleUsers(ids: string[]): Promise<User[]> {
  const promises = ids.map(id => fetchUser(id));
  return Promise.all(promises);
}
```

## Avoid 'any' - Usa 'unknown'

```typescript
// ❌ MAL: any desactiva type checking
function processData(data: any) {
  return data.value.toUpperCase(); // No error si data.value no existe
}

// ✅ BIEN: unknown requiere type checking
function processData(data: unknown) {
  if (
    typeof data === 'object' &&
    data !== null &&
    'value' in data &&
    typeof data.value === 'string'
  ) {
    return data.value.toUpperCase();
  }
  throw new Error('Invalid data');
}

// Mejor aún: Define el type
interface DataWithValue {
  value: string;
}

function processData(data: DataWithValue) {
  return data.value.toUpperCase();
}
```

## Discriminated Unions (Tagged Unions)

```typescript
interface LoadingState {
  status: 'loading';
}

interface SuccessState {
  status: 'success';
  data: User[];
}

interface ErrorState {
  status: 'error';
  error: string;
}

type FetchState = LoadingState | SuccessState | ErrorState;

function renderUsers(state: FetchState) {
  switch (state.status) {
    case 'loading':
      return 'Loading...';

    case 'success':
      // TypeScript sabe que state.data existe aquí
      return state.data.map(user => user.name).join(', ');

    case 'error':
      // Y que state.error existe aquí
      return `Error: ${state.error}`;
  }
}
```

## Readonly e Immutability

```typescript
// Readonly en interfaces
interface User {
  readonly id: string;
  name: string;
}

const user: User = { id: '1', name: 'John' };
// user.id = '2'; // ❌ Error: Cannot assign to 'id' because it is a read-only property

// Readonly utility type
type ReadonlyUser = Readonly<User>;

// Arrays readonly
function sum(numbers: readonly number[]): number {
  // numbers.push(5); // ❌ Error: Property 'push' does not exist
  return numbers.reduce((a, b) => a + b, 0);
}

// as const para literals
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;

// config.apiUrl = 'other'; // ❌ Error
```

## Testing con TypeScript

```typescript
import { describe, it, expect, vi } from 'vitest';

describe('UserService', () => {
  it('should create user successfully', async () => {
    // Arrange
    const mockRepo = {
      save: vi.fn().mockResolvedValue(undefined),
      findByEmail: vi.fn().mockResolvedValue(null),
    };

    const service = new UserService(mockRepo);

    // Act
    const user = await service.createUser('test@example.com');

    // Assert
    expect(user.email).toBe('test@example.com');
    expect(mockRepo.save).toHaveBeenCalledWith(user);
  });
});

// Type-safe mocks
type MockRepository = {
  [K in keyof UserRepository]: ReturnType<typeof vi.fn>;
};
```

## Comandos Útiles

```bash
# Type checking
tsc --noEmit

# Watch mode
tsc --watch

# Build
tsc

# Testing (con Vitest)
vitest
vitest run

# Linting (con ESLint)
eslint . --ext .ts,.tsx
```

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- Detectes TypeScript 5.x con nuevas features
- Encuentres mejores patrones de types/generics
- Veas nuevos utility types útiles

**Preserva siempre**:
- Convenciones de naming
- Preferencia por type safety estricto
- Avoid any, prefer unknown

**Usa Context7**:
```typescript
resolve-library-id: "microsoft/TypeScript"
query-docs: "latest TypeScript features 2026"
```
