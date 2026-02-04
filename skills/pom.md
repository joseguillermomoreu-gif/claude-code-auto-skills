# Page Object Model (POM) - E2E Testing Pattern

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Context7 enabled

---

## Introducción

Page Object Model (POM) es un patrón de diseño para testing E2E que encapsula la estructura y elementos de una página en una clase.

**Objetivo:** Separar la lógica de los tests de los detalles de implementación de la UI.

**Beneficios:**
- ✅ Tests más legibles (DSL del dominio)
- ✅ Mantenibilidad (cambios de UI en un solo lugar)
- ✅ Reutilización de código
- ✅ Reduce duplicación
- ✅ Abstrae selectores

---

## Principios Fundamentales

### 1. **Una clase por página/componente**

Cada página o componente principal tiene su propio Page Object.

### 2. **Selectores SOLO en Page Objects**

NUNCA en los tests:
```typescript
// ❌ MAL: Selector en test
test('login', async ({ page }) => {
    await page.click('#login-button'); // ❌ Selector directo
});

// ✅ BIEN: Selector en Page Object
test('login', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.clickLogin(); // ✅ Método descriptivo
});
```

### 3. **Métodos representan acciones del usuario**

No getters de elementos, sino acciones:
```typescript
// ❌ MAL
getEmailInput() { return this.page.locator('#email'); }

// ✅ BIEN
async fillEmail(email: string) {
    await this.page.locator('#email').fill(email);
}
```

### 4. **Retornar Page Objects, no void**

Para fluent interface:
```typescript
class LoginPage {
    async login(email: string, password: string): Promise<DashboardPage> {
        await this.fillEmail(email);
        await this.fillPassword(password);
        await this.clickSubmit();
        return new DashboardPage(this.page); // ✅ Retorna siguiente página
    }
}

// Test fluido
const dashboard = await loginPage.login('user@test.com', 'pass');
await dashboard.verifyWelcomeMessage();
```

---

## Estructura Básica

### Page Object Simple

```typescript
// pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
    readonly page: Page;

    // Selectores privados
    private readonly emailInput: Locator;
    private readonly passwordInput: Locator;
    private readonly submitButton: Locator;
    private readonly errorMessage: Locator;

    constructor(page: Page) {
        this.page = page;

        // Inicializar locators
        this.emailInput = page.locator('#email');
        this.passwordInput = page.locator('#password');
        this.submitButton = page.locator('button[type="submit"]');
        this.errorMessage = page.locator('.error-message');
    }

    // Navegación
    async goto() {
        await this.page.goto('/login');
    }

    // Acciones
    async fillEmail(email: string) {
        await this.emailInput.fill(email);
    }

    async fillPassword(password: string) {
        await this.passwordInput.fill(password);
    }

    async clickSubmit() {
        await this.submitButton.click();
    }

    // Método de alto nivel
    async login(email: string, password: string): Promise<DashboardPage> {
        await this.fillEmail(email);
        await this.fillPassword(password);
        await this.clickSubmit();

        return new DashboardPage(this.page);
    }

    // Assertions
    async expectErrorMessage(text: string) {
        await expect(this.errorMessage).toHaveText(text);
    }

    async isErrorVisible(): Promise<boolean> {
        return await this.errorMessage.isVisible();
    }
}
```

### Test Usando Page Object

```typescript
// tests/login.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

test.describe('Login', () => {
    let loginPage: LoginPage;

    test.beforeEach(async ({ page }) => {
        loginPage = new LoginPage(page);
        await loginPage.goto();
    });

    test('successful login', async () => {
        const dashboard = await loginPage.login('user@test.com', 'password123');

        await dashboard.expectWelcomeMessage('Welcome!');
    });

    test('invalid credentials show error', async () => {
        await loginPage.login('wrong@test.com', 'wrong');

        await loginPage.expectErrorMessage('Invalid credentials');
    });
});
```

---

## Page Components (Fragmentos Reutilizables)

```typescript
// components/NavigationComponent.ts
export class NavigationComponent {
    readonly page: Page;
    private readonly homeLink: Locator;
    private readonly profileLink: Locator;
    private readonly logoutButton: Locator;

    constructor(page: Page) {
        this.page = page;
        this.homeLink = page.locator('nav a[href="/"]');
        this.profileLink = page.locator('nav a[href="/profile"]');
        this.logoutButton = page.locator('nav button:has-text("Logout")');
    }

    async goToHome() {
        await this.homeLink.click();
    }

    async goToProfile() {
        await this.profileLink.click();
    }

    async logout() {
        await this.logoutButton.click();
    }
}

// Uso en Page Object
export class DashboardPage {
    readonly navigation: NavigationComponent;

    constructor(page: Page) {
        this.navigation = new NavigationComponent(page);
    }

    async navigateToProfile() {
        await this.navigation.goToProfile();
    }
}

// En test
const dashboard = new DashboardPage(page);
await dashboard.navigation.goToProfile(); // ✅ Composición
```

---

## Base Page Class

```typescript
// pages/BasePage.ts
export abstract class BasePage {
    readonly page: Page;

    constructor(page: Page) {
        this.page = page;
    }

    // Helpers comunes
    async waitForPageLoad() {
        await this.page.waitForLoadState('networkidle');
    }

    async scrollToBottom() {
        await this.page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    }

    async takeScreenshot(name: string) {
        await this.page.screenshot({ path: `screenshots/${name}.png` });
    }

    async getCurrentUrl(): Promise<string> {
        return this.page.url();
    }

    async refreshPage() {
        await this.page.reload();
    }
}

// Extender en Page Objects concretos
export class LoginPage extends BasePage {
    private readonly emailInput: Locator;

    constructor(page: Page) {
        super(page);
        this.emailInput = page.locator('#email');
    }

    async login(email: string, password: string) {
        // ... login logic
        await this.waitForPageLoad(); // ✅ Heredado de BasePage
    }
}
```

---

## Locator Strategies

### ✅ BIEN: Locators Robustos

```typescript
// Por data-testid (preferido)
private readonly submitButton = this.page.locator('[data-testid="submit-btn"]');

// Por role (accesibilidad)
private readonly heading = this.page.getByRole('heading', { name: 'Login' });
private readonly submitButton = this.page.getByRole('button', { name: 'Submit' });

// Por label (forms)
private readonly emailInput = this.page.getByLabel('Email address');

// Por placeholder
private readonly searchInput = this.page.getByPlaceholder('Search...');

// Por texto
private readonly welcomeMessage = this.page.getByText('Welcome back!');
```

### ❌ MAL: Locators Frágiles

```typescript
// ❌ IDs generados dinámicamente
this.page.locator('#user-123456');

// ❌ Clases CSS de estilos
this.page.locator('.btn-primary'); // Cambia con diseño

// ❌ XPath complejos
this.page.locator('//div[@class="container"]/div[2]/span[1]');

// ❌ Nth selectors
this.page.locator('button >> nth=3'); // Frágil si orden cambia
```

---

## Wait Strategies

```typescript
export class ProductPage extends BasePage {
    private readonly addToCartButton: Locator;
    private readonly successMessage: Locator;

    async addToCart(): Promise<void> {
        // Wait for button to be enabled
        await this.addToCartButton.waitFor({ state: 'visible' });
        await this.addToCartButton.click();

        // Wait for success message
        await this.successMessage.waitFor({ state: 'visible', timeout: 5000 });
    }

    async waitForProductsToLoad(): Promise<void> {
        // Wait for API response
        await this.page.waitForResponse(
            response => response.url().includes('/api/products') && response.status() === 200
        );
    }

    async waitForAnimation(): Promise<void> {
        // Wait for CSS animation
        await this.page.waitForTimeout(500); // ⚠️ Usar solo cuando sea necesario
    }
}
```

---

## Assertions en Page Objects

### Opción 1: Métodos de Verificación

```typescript
export class DashboardPage {
    private readonly welcomeMessage: Locator;

    async expectWelcomeMessage(text: string) {
        await expect(this.welcomeMessage).toHaveText(text);
    }

    async isWelcomeMessageVisible(): Promise<boolean> {
        return await this.welcomeMessage.isVisible();
    }
}

// En test
await dashboard.expectWelcomeMessage('Welcome, John!');
```

### Opción 2: Solo Getters (assertions en test)

```typescript
export class DashboardPage {
    getWelcomeMessage(): Locator {
        return this.page.locator('.welcome-message');
    }
}

// En test
await expect(dashboard.getWelcomeMessage()).toHaveText('Welcome!');
```

**Recomendación:** Opción 1 (assertions en PO) para mejor abstracción.

---

## Patrones Avanzados

### Factory Pattern

```typescript
// pages/PageFactory.ts
export class PageFactory {
    static createLoginPage(page: Page): LoginPage {
        return new LoginPage(page);
    }

    static createDashboardPage(page: Page): DashboardPage {
        return new DashboardPage(page);
    }

    static createProductPage(page: Page, productId: string): ProductPage {
        const productPage = new ProductPage(page);
        productPage.setProductId(productId);
        return productPage;
    }
}

// En test
const loginPage = PageFactory.createLoginPage(page);
```

### Fluent Interface

```typescript
export class SearchPage {
    async search(query: string): this {
        await this.searchInput.fill(query);
        await this.searchButton.click();
        return this; // ✅ Retorna this para encadenar
    }

    async filterByCategory(category: string): this {
        await this.categoryDropdown.selectOption(category);
        return this;
    }

    async sortBy(option: string): this {
        await this.sortDropdown.selectOption(option);
        return this;
    }
}

// Uso fluido
await searchPage
    .search('laptop')
    .filterByCategory('Electronics')
    .sortBy('price-low-to-high');
```

### Page Object con State

```typescript
export class ProductPage {
    private productId?: string;

    setProductId(id: string): void {
        this.productId = id;
    }

    async goto(): Promise<void> {
        if (!this.productId) {
            throw new Error('Product ID not set');
        }
        await this.page.goto(`/products/${this.productId}`);
    }
}
```

---

## Organización de Archivos

```
tests/
├── pages/
│   ├── BasePage.ts
│   ├── LoginPage.ts
│   ├── DashboardPage.ts
│   ├── ProductPage.ts
│   └── CheckoutPage.ts
│
├── components/
│   ├── NavigationComponent.ts
│   ├── HeaderComponent.ts
│   └── FooterComponent.ts
│
├── specs/
│   ├── login.spec.ts
│   ├── checkout.spec.ts
│   └── search.spec.ts
│
└── fixtures/
    └── test-data.ts
```

---

## Anti-Patterns

### ❌ Selectores en Tests

```typescript
// ❌ MAL
test('login', async ({ page }) => {
    await page.fill('#email', 'user@test.com');
    await page.fill('#password', 'pass123');
    await page.click('button[type="submit"]');
});

// ✅ BIEN
test('login', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.login('user@test.com', 'pass123');
});
```

### ❌ Métodos Genéricos

```typescript
// ❌ MAL: Muy genérico
async fillField(selector: string, value: string) {
    await this.page.fill(selector, value);
}

// ✅ BIEN: Específico del dominio
async fillEmail(email: string) {
    await this.emailInput.fill(email);
}
```

### ❌ Lógica de Negocio en PO

```typescript
// ❌ MAL: Validación de negocio en PO
async login(email: string, password: string) {
    if (!email.includes('@')) {
        throw new Error('Invalid email');
    }
    // ...
}

// ✅ BIEN: PO solo interactúa con UI
async login(email: string, password: string) {
    await this.fillEmail(email);
    await this.fillPassword(password);
    await this.clickSubmit();
}
```

---

## Best Practices

### ✅ DO

```typescript
// Page Object = Métodos de acción
async clickSubmit() { /* ... */ }

// Selectores privados
private readonly button: Locator;

// Retornar Page Objects
async login(): Promise<DashboardPage> { /* ... */ }

// Nombres descriptivos
async fillEmailAddress(email: string) { /* ... */ }

// Wait strategies explícitas
await this.element.waitFor({ state: 'visible' });

// Componentes reutilizables
readonly navigation: NavigationComponent;
```

### ❌ DON'T

```typescript
// Selectores públicos
public readonly button: Locator; // ❌

// Getters de elementos
getEmailInput() { return this.emailInput; } // ❌

// Métodos genéricos
async click(selector: string) {} // ❌

// Hardcoded waits
await this.page.waitForTimeout(3000); // ❌

// Lógica de negocio
if (isAdmin) { /* ... */ } // ❌
```

---

## 🔄 Auto-Mantenimiento con Context7

**Library tracked:** `/microsoft/playwright`

**Actualización automática:**
```
mcp__context7__resolve-library-id: libraryName="Playwright"
mcp__context7__query-docs: libraryId="/microsoft/playwright", query="latest Playwright Page Object Model best practices"
```

**Qué se actualiza:**
- ✅ Nuevos locator strategies
- ✅ Wait patterns mejorados
- ✅ Breaking changes en API
- ✅ Performance best practices
- ✅ Accessibility patterns

**Qué se preserva:**
- ✅ Estructura de Page Objects establecida
- ✅ Naming conventions del proyecto
- ✅ Patrones de organización preferidos

**Frecuencia:** Automática cuando detecta nueva versión

**Última sync:** 2026-02-04
**Versión tracked:** Playwright 1.40+

---

*Organismo viviente: Context7 + Experiencia comunitaria + Tu uso*
