# React - Modern UI Library con Hooks

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Context7 enabled

---

## Introducción

React es una biblioteca de JavaScript para construir interfaces de usuario, desarrollada por Meta (Facebook).

**Características:**
- Component-based architecture
- Virtual DOM para performance
- Unidirectional data flow
- Hooks para lógica reutilizable
- Ecosistema rico (Router, State Management, etc.)

**Versión actual:** React 18+ (Concurrent features)

---

## Componentes Funcionales (Recomendado)

```tsx
// TypeScript + React
import React from 'react';

interface UserCardProps {
    name: string;
    email: string;
    age?: number;
}

export const UserCard: React.FC<UserCardProps> = ({ name, email, age }) => {
    return (
        <div className="user-card">
            <h3>{name}</h3>
            <p>{email}</p>
            {age && <span>Age: {age}</span>}
        </div>
    );
};

// Usage
<UserCard name="John" email="john@example.com" />
```

**NO uses class components** (deprecated pattern):
```tsx
// ❌ MAL (legacy)
class UserCard extends React.Component {
    render() {
        return <div>...</div>
    }
}

// ✅ BIEN (moderno)
const UserCard = ({ name, email }) => {
    return <div>...</div>
}
```

---

## Hooks Fundamentales

### useState - State Local

```tsx
import { useState } from 'react';

function Counter() {
    const [count, setCount] = useState<number>(0);

    const increment = () => setCount(count + 1);
    const decrement = () => setCount(c => c - 1); // ✅ Functional update

    return (
        <div>
            <p>Count: {count}</p>
            <button onClick={increment}>+</button>
            <button onClick={decrement}>-</button>
        </div>
    );
}

// Multiple state
function LoginForm() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

    // ...
}

// Object state (mejor separados si cambian independientemente)
function UserForm() {
    const [user, setUser] = useState({ name: '', email: '' });

    const updateName = (name: string) => {
        setUser({ ...user, name }); // ⚠️ Spread to preserve email
    };
}
```

### useEffect - Side Effects

```tsx
import { useEffect } from 'react';

function UserProfile({ userId }: { userId: number }) {
    const [user, setUser] = useState<User | null>(null);

    // Fetch on mount and when userId changes
    useEffect(() => {
        const fetchUser = async () => {
            const response = await fetch(`/api/users/${userId}`);
            const data = await response.json();
            setUser(data);
        };

        fetchUser();
    }, [userId]); // ✅ Dependency array

    return user ? <div>{user.name}</div> : <div>Loading...</div>;
}

// Cleanup function
useEffect(() => {
    const interval = setInterval(() => {
        console.log('Tick');
    }, 1000);

    // ✅ Cleanup on unmount
    return () => clearInterval(interval);
}, []);

// Run once on mount (empty deps)
useEffect(() => {
    console.log('Component mounted');
}, []);

// Run on every render (no deps) - ⚠️ Evita esto
useEffect(() => {
    console.log('Every render'); // ⚠️ Expensive
});
```

### useContext - Global State

```tsx
import { createContext, useContext, useState } from 'react';

// 1. Create context
interface AuthContextType {
    user: User | null;
    login: (email: string, password: string) => Promise<void>;
    logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// 2. Provider component
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [user, setUser] = useState<User | null>(null);

    const login = async (email: string, password: string) => {
        const response = await fetch('/api/login', {
            method: 'POST',
            body: JSON.stringify({ email, password })
        });
        const data = await response.json();
        setUser(data.user);
    };

    const logout = () => setUser(null);

    return (
        <AuthContext.Provider value={{ user, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
};

// 3. Custom hook for consuming
export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within AuthProvider');
    }
    return context;
};

// 4. Usage
function App() {
    return (
        <AuthProvider>
            <Navbar />
            <Routes />
        </AuthProvider>
    );
}

function Navbar() {
    const { user, logout } = useAuth();

    return (
        <nav>
            {user ? (
                <>
                    <span>{user.name}</span>
                    <button onClick={logout}>Logout</button>
                </>
            ) : (
                <a href="/login">Login</a>
            )}
        </nav>
    );
}
```

### useRef - Referencias Mutables

```tsx
import { useRef } from 'react';

function TextInput() {
    const inputRef = useRef<HTMLInputElement>(null);

    const focusInput = () => {
        inputRef.current?.focus(); // ✅ Access DOM node
    };

    return (
        <>
            <input ref={inputRef} type="text" />
            <button onClick={focusInput}>Focus</button>
        </>
    );
}

// Store mutable value (no re-render on change)
function Timer() {
    const intervalRef = useRef<number>();

    useEffect(() => {
        intervalRef.current = setInterval(() => {
            console.log('Tick');
        }, 1000);

        return () => clearInterval(intervalRef.current);
    }, []);

    return <div>Timer running...</div>;
}
```

### useMemo - Memoize Expensive Calculations

```tsx
import { useMemo } from 'react';

function ProductList({ products, filter }: Props) {
    // ✅ Only recalculate when products or filter change
    const filteredProducts = useMemo(() => {
        return products.filter(p => p.name.includes(filter));
    }, [products, filter]);

    return (
        <ul>
            {filteredProducts.map(p => (
                <li key={p.id}>{p.name}</li>
            ))}
        </ul>
    );
}

// ❌ Without useMemo: recalculates on every render
function ProductList({ products, filter }) {
    const filteredProducts = products.filter(p => p.name.includes(filter));
    // This runs on EVERY render, even if products/filter didn't change
}
```

### useCallback - Memoize Functions

```tsx
import { useCallback } from 'react';

function Parent() {
    const [count, setCount] = useState(0);

    // ✅ Memoized function, same reference unless count changes
    const handleClick = useCallback(() => {
        console.log('Clicked with count:', count);
    }, [count]);

    return <Child onClick={handleClick} />;
}

// Child only re-renders if handleClick reference changes
const Child = React.memo(({ onClick }: { onClick: () => void }) => {
    console.log('Child rendered');
    return <button onClick={onClick}>Click</button>;
});
```

---

## Custom Hooks

```tsx
// useFetch - Reusable data fetching
function useFetch<T>(url: string) {
    const [data, setData] = useState<T | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<Error | null>(null);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await fetch(url);
                const json = await response.json();
                setData(json);
            } catch (err) {
                setError(err as Error);
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, [url]);

    return { data, loading, error };
}

// Usage
function UserProfile({ userId }: { userId: number }) {
    const { data: user, loading, error } = useFetch<User>(`/api/users/${userId}`);

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;
    if (!user) return <div>Not found</div>;

    return <div>{user.name}</div>;
}

// useLocalStorage - Persist state
function useLocalStorage<T>(key: string, initialValue: T) {
    const [value, setValue] = useState<T>(() => {
        const stored = localStorage.getItem(key);
        return stored ? JSON.parse(stored) : initialValue;
    });

    useEffect(() => {
        localStorage.setItem(key, JSON.stringify(value));
    }, [key, value]);

    return [value, setValue] as const;
}

// Usage
function Settings() {
    const [theme, setTheme] = useLocalStorage('theme', 'light');

    return (
        <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
            Toggle theme
        </button>
    );
}
```

---

## Props y Types (TypeScript)

```tsx
// Basic props
interface ButtonProps {
    text: string;
    onClick: () => void;
    disabled?: boolean;
}

export const Button: React.FC<ButtonProps> = ({ text, onClick, disabled = false }) => {
    return (
        <button onClick={onClick} disabled={disabled}>
            {text}
        </button>
    );
};

// Children prop
interface CardProps {
    title: string;
    children: React.ReactNode;
}

export const Card: React.FC<CardProps> = ({ title, children }) => {
    return (
        <div className="card">
            <h3>{title}</h3>
            {children}
        </div>
    );
};

// Generic component
interface ListProps<T> {
    items: T[];
    renderItem: (item: T) => React.ReactNode;
}

export function List<T>({ items, renderItem }: ListProps<T>) {
    return (
        <ul>
            {items.map((item, index) => (
                <li key={index}>{renderItem(item)}</li>
            ))}
        </ul>
    );
}

// Usage
<List
    items={users}
    renderItem={user => <span>{user.name}</span>}
/>
```

---

## Conditional Rendering

```tsx
function UserGreeting({ user }: { user: User | null }) {
    // If/else
    if (!user) {
        return <div>Please login</div>;
    }

    return <div>Welcome, {user.name}</div>;
}

function ProductCard({ product }: { product: Product }) {
    return (
        <div>
            <h3>{product.name}</h3>

            {/* Conditional with && */}
            {product.onSale && <span className="badge">Sale!</span>}

            {/* Ternary */}
            {product.stock > 0 ? (
                <button>Add to cart</button>
            ) : (
                <span>Out of stock</span>
            )}

            {/* Optional chaining */}
            {product.reviews?.length > 0 && (
                <div>Reviews: {product.reviews.length}</div>
            )}
        </div>
    );
}
```

---

## Lists y Keys

```tsx
function ProductList({ products }: { products: Product[] }) {
    return (
        <ul>
            {products.map(product => (
                // ✅ BIEN: Unique, stable key
                <li key={product.id}>
                    {product.name}
                </li>
            ))}
        </ul>
    );
}

// ❌ MAL: Index as key (problemas con reordering)
products.map((product, index) => (
    <li key={index}>{product.name}</li>
));
```

---

## Forms

```tsx
function LoginForm() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        console.log('Login:', { email, password });
    };

    return (
        <form onSubmit={handleSubmit}>
            <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="Email"
            />
            <input
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="Password"
            />
            <button type="submit">Login</button>
        </form>
    );
}

// Controlled component pattern
function ControlledInput() {
    const [value, setValue] = useState('');

    return (
        <input
            value={value}
            onChange={e => setValue(e.target.value)}
        />
    );
}
```

---

## Performance Optimization

### React.memo

```tsx
// Only re-render if props change
const ExpensiveComponent = React.memo(({ data }: { data: Data }) => {
    console.log('Rendering expensive component');
    return <div>{/* Complex UI */}</div>;
});

// Custom comparison
const UserCard = React.memo(
    ({ user }: { user: User }) => <div>{user.name}</div>,
    (prevProps, nextProps) => prevProps.user.id === nextProps.user.id
);
```

### Lazy Loading

```tsx
import { lazy, Suspense } from 'react';

// Lazy load component
const Dashboard = lazy(() => import('./Dashboard'));

function App() {
    return (
        <Suspense fallback={<div>Loading...</div>}>
            <Dashboard />
        </Suspense>
    );
}
```

---

## Best Practices

### ✅ DO

```tsx
// Functional components with hooks
const MyComponent: React.FC = () => { /* ... */ };

// Type props with TypeScript
interface Props { name: string; }

// Descriptive names
const UserProfileCard: React.FC<Props> = ({ name }) => {};

// Extract custom hooks for reusable logic
const useFetch = (url: string) => { /* ... */ };

// Memoize expensive calculations
const result = useMemo(() => expensiveCalc(), [deps]);

// Dependency arrays in useEffect
useEffect(() => { /* ... */ }, [dep1, dep2]);

// Key prop in lists with stable IDs
{items.map(item => <div key={item.id}>{item.name}</div>)}

// Controlled components for forms
<input value={val} onChange={e => setVal(e.target.value)} />
```

### ❌ DON'T

```tsx
// Class components (legacy)
class MyComponent extends React.Component {} // ❌

// Missing TypeScript types
const MyComponent = ({ name }) => {}; // ❌ No type for name

// Index as key (unstable)
{items.map((item, i) => <div key={i}>{item}</div>)} // ❌

// Mutation of state
const [user, setUser] = useState({ name: 'John' });
user.name = 'Jane'; // ❌ Mutate directly
setUser({ ...user, name: 'Jane' }); // ✅ Immutable update

// Missing deps in useEffect
useEffect(() => {
    doSomethingWith(userId); // ❌ userId not in deps
}, []);

// Premature optimization
const value = useMemo(() => x + y, [x, y]); // ❌ Simple calc, no need

// Nested component definitions
function Parent() {
    // ❌ Re-creates Child on every render
    function Child() { return <div>Child</div> }
    return <Child />;
}
```

---

## 🔄 Auto-Mantenimiento con Context7

**Library tracked:** `/facebook/react`

**Actualización automática:**
```
mcp__context7__resolve-library-id: libraryName="React"
mcp__context7__query-docs: libraryId="/facebook/react", query="latest React 19 features and concurrent rendering patterns"
```

**Qué se actualiza:**
- ✅ Nuevos hooks (React 19+)
- ✅ Concurrent features
- ✅ Server Components patterns
- ✅ Breaking changes
- ✅ Performance best practices

**Qué se preserva:**
- ✅ TypeScript patterns establecidos
- ✅ Custom hooks del proyecto
- ✅ Arquitectura de componentes preferida

**Frecuencia:** Automática cuando detecta nueva versión

**Última sync:** 2026-02-04
**Versión tracked:** React 18.x

---

*Organismo viviente: Context7 + Experiencia comunitaria + Tu uso*
