# Playwright E2E Testing - Convenciones POM

> **Stack**: Playwright + TypeScript
> **Patrón**: Page Object Model (POM) estricto
> **Última actualización**: 2026-02-04

## Arquitectura POM Obligatoria

```
tests/
├── pages/              # Page Objects (única fuente de selectores)
│   ├── BasePage.ts
│   ├── LoginPage.ts
│   └── DashboardPage.ts
├── specs/              # Tests (NO selectores aquí)
│   ├── auth.spec.ts
│   └── dashboard.spec.ts
└── fixtures/           # Datos de test
    └── users.json
```

## Reglas Estrictas

### ❌ NUNCA hacer en specs:
```typescript
// MAL: Selectores en tests
test('login', async ({ page }) => {
  await page.click('#login-button');  // ❌ NO
  await page.fill('input[name="email"]', 'test@test.com');  // ❌ NO
});
```

### ✅ SIEMPRE hacer:
```typescript
// BIEN: Page Object
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  // Selectores privados (encapsulados)
  private selectors = {
    emailInput: 'input[name="email"]',
    passwordInput: 'input[name="password"]',
    submitButton: '#login-button',
    errorMessage: '.error-toast'
  };

  // Métodos públicos (API del page)
  async login(email: string, password: string): Promise<void> {
    await this.page.fill(this.selectors.emailInput, email);
    await this.page.fill(this.selectors.passwordInput, password);
    await this.page.click(this.selectors.submitButton);
  }

  async getErrorMessage(): Promise<string> {
    return await this.page.textContent(this.selectors.errorMessage) ?? '';
  }
}

// specs/auth.spec.ts
test('login fails with invalid credentials', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('invalid@test.com', 'wrong');

  const error = await loginPage.getErrorMessage();
  expect(error).toContain('Invalid credentials');
});
```

## Naming Conventions

### Archivos
```
✅ login.spec.ts          # spec.ts suffix
✅ LoginPage.ts           # PascalCase para pages
✅ userFixtures.ts        # camelCase para utils
```

### Métodos de Page Objects
```typescript
class CheckoutPage {
  // Acciones: verbos imperativos
  async fillShippingAddress(address: Address): Promise<void>
  async selectPaymentMethod(method: PaymentMethod): Promise<void>
  async submitOrder(): Promise<void>

  // Queries: get/is/has prefix
  async getOrderTotal(): Promise<number>
  async isPaymentSectionVisible(): Promise<boolean>
  async hasErrorMessages(): Promise<boolean>

  // Navegación: goto prefix
  async gotoCheckout(): Promise<void>
}
```

### Tests
```typescript
// Patrón: "should describe what it does"
test('should display error when email is invalid', async ({ page }) => {
  // ...
});

test('should redirect to dashboard after successful login', async ({ page }) => {
  // ...
});
```

## BasePage Pattern

```typescript
// pages/BasePage.ts
import { Page } from '@playwright/test';

export class BasePage {
  constructor(protected page: Page) {}

  // Métodos comunes a todas las páginas
  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
  }

  async screenshot(name: string): Promise<void> {
    await this.page.screenshot({ path: `screenshots/${name}.png` });
  }

  async getTitle(): Promise<string> {
    return await this.page.title();
  }

  async goto(url: string): Promise<void> {
    await this.page.goto(url);
    await this.waitForPageLoad();
  }
}

// Herencia en page objects
export class LoginPage extends BasePage {
  async gotoLogin(): Promise<void> {
    await this.goto('/login');
  }

  // ... métodos específicos
}
```

## Fixtures y Test Setup

```typescript
// tests/fixtures/auth.fixture.ts
import { test as base, Page } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

type AuthFixtures = {
  authenticatedPage: Page;
  loginPage: LoginPage;
};

export const test = base.extend<AuthFixtures>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },

  authenticatedPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('user@test.com', 'password');
    await use(page);
  }
});

export { expect } from '@playwright/test';

// Uso en specs
import { test, expect } from './fixtures/auth.fixture';

test('dashboard shows user data', async ({ authenticatedPage }) => {
  const dashboard = new DashboardPage(authenticatedPage);
  const username = await dashboard.getUsername();
  expect(username).toBe('Test User');
});
```

## Selectores: Best Practices

```typescript
// Prioridad de selectores (de mejor a peor):

// 1. data-testid (MEJOR - específico para testing)
page.locator('[data-testid="submit-button"]')

// 2. Role + name (accesibilidad)
page.getByRole('button', { name: 'Submit' })

// 3. Label text
page.getByLabel('Email address')

// 4. Placeholder
page.getByPlaceholder('Enter your email')

// 5. Text content
page.getByText('Welcome back')

// 6. CSS selector (ÚLTIMO RECURSO)
page.locator('#submit-btn')
```

### Ejemplo completo:
```typescript
export class LoginPage extends BasePage {
  // Usar métodos de Playwright nativos cuando sea posible
  async fillEmail(email: string): Promise<void> {
    await this.page.getByLabel('Email').fill(email);
  }

  async fillPassword(password: string): Promise<void> {
    await this.page.getByLabel('Password').fill(password);
  }

  async clickSubmit(): Promise<void> {
    await this.page.getByRole('button', { name: 'Sign in' }).click();
  }

  // O combinado en un método
  async login(email: string, password: string): Promise<void> {
    await this.fillEmail(email);
    await this.fillPassword(password);
    await this.clickSubmit();
  }
}
```

## Assertions Comunes

```typescript
import { expect } from '@playwright/test';

// Visibilidad
await expect(page.getByText('Welcome')).toBeVisible();
await expect(page.getByText('Error')).toBeHidden();

// Contenido
await expect(page).toHaveTitle('Dashboard');
await expect(page.getByRole('heading')).toHaveText('Dashboard');
await expect(page.getByTestId('username')).toContainText('John');

// URL
await expect(page).toHaveURL('/dashboard');
await expect(page).toHaveURL(/.*dashboard/);

// Estado de elementos
await expect(page.getByRole('button')).toBeEnabled();
await expect(page.getByRole('checkbox')).toBeChecked();

// Count
await expect(page.getByRole('listitem')).toHaveCount(5);
```

## Esperas y Timeouts

```typescript
// ✅ BIEN: Esperas implícitas (Playwright espera automáticamente)
await page.click('button'); // Espera a que sea clickable

// ✅ BIEN: Espera explícita cuando sea necesario
await page.waitForSelector('[data-testid="results"]');
await page.waitForLoadState('networkidle');

// ❌ MAL: Sleeps arbitrarios
await page.waitForTimeout(5000); // Evitar
```

## Debugging

```typescript
// Breakpoint interactivo
await page.pause();

// Screenshot on failure (configurado en playwright.config.ts)
use: {
  screenshot: 'only-on-failure',
  video: 'retain-on-failure',
  trace: 'on-first-retry',
}

// Debug en test específico
test.only('debug this test', async ({ page }) => {
  await page.pause(); // Abre inspector
});
```

## Configuración Playwright (playwright.config.ts)

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/specs',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
  ],

  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
  ],
});
```

## Comandos Frecuentes

```bash
# Desarrollo
npx playwright test --ui              # Modo UI interactivo
npx playwright test --debug           # Con breakpoints
npx playwright test auth.spec.ts      # Test específico
npx playwright test --headed          # Ver browser
npx playwright test --grep "login"    # Tests que matchean pattern

# CI/CD
npx playwright test --reporter=html   # Report HTML
npx playwright test --shard=1/4       # Paralelización

# Codegen (genera selectores)
npx playwright codegen localhost:3000
```

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- Detectes nuevas best practices de Playwright
- Veas patrones repetidos que deberían estar documentados
- Encuentres anti-patterns en mi código

**Preserva siempre**:
- Reglas POM estrictas
- Naming conventions definidas
- Estructura de directorios

**Usa Context7**:
```typescript
resolve-library-id: "microsoft/playwright"
query-docs: "latest Playwright features 2026"
```
