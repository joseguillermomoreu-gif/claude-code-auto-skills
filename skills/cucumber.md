# Cucumber - BDD Testing con Playwright

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Context7 enabled

---

## Introducción

Cucumber es un framework para Behavior-Driven Development (BDD) que permite escribir tests en lenguaje natural (Gherkin).

**Beneficios:**
- Tests legibles por no-técnicos (stakeholders, PO, QA)
- Especificación ejecutable (documentación viva)
- Colaboración entre negocio y desarrollo
- Reutilización de step definitions

**Integración:** Cucumber + Playwright para E2E testing

---

## Instalación

```bash
npm install --save-dev @cucumber/cucumber @playwright/test
npm install --save-dev ts-node typescript @types/node
```

**cucumber.js:**
```javascript
module.exports = {
    default: {
        require: ['features/step-definitions/**/*.ts'],
        requireModule: ['ts-node/register'],
        format: ['progress', 'html:reports/cucumber-report.html'],
        formatOptions: { snippetInterface: 'async-await' },
        publishQuiet: true
    }
};
```

**tsconfig.json:**
```json
{
    "compilerOptions": {
        "target": "ES2020",
        "module": "commonjs",
        "esModuleInterop": true,
        "skipLibCheck": true,
        "strict": true
    }
}
```

---

## Gherkin Syntax

### Feature File

**features/login.feature:**
```gherkin
Feature: User Login
  As a registered user
  I want to log into the system
  So that I can access my account

  Background:
    Given the user is on the login page

  Scenario: Successful login with valid credentials
    Given the user has an account with email "user@test.com"
    When the user enters email "user@test.com"
    And the user enters password "SecurePass123!"
    And the user clicks the submit button
    Then the user should be redirected to the dashboard
    And the user should see a welcome message "Welcome back!"

  Scenario: Failed login with invalid credentials
    When the user enters email "wrong@test.com"
    And the user enters password "wrongpassword"
    And the user clicks the submit button
    Then the user should see an error message "Invalid credentials"
    And the user should remain on the login page

  Scenario Outline: Login attempts with different credentials
    When the user enters email "<email>"
    And the user enters password "<password>"
    And the user clicks the submit button
    Then the user should see "<result>"

    Examples:
      | email          | password    | result              |
      | user@test.com  | correct123  | Welcome back!       |
      | wrong@test.com | wrong456    | Invalid credentials |
      | admin@test.com | admin789    | Welcome, Admin!     |
```

### Keywords

- **Feature:** Describe la funcionalidad a probar
- **Background:** Steps comunes a todos los scenarios
- **Scenario:** Caso de prueba individual
- **Given:** Precondiciones (estado inicial)
- **When:** Acciones del usuario
- **Then:** Resultados esperados
- **And:** Continuación de Given/When/Then
- **But:** Negación (igual que And)

---

## Step Definitions

**features/step-definitions/login.steps.ts:**
```typescript
import { Given, When, Then, setDefaultTimeout } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { LoginPage } from '../../pages/LoginPage';
import { DashboardPage } from '../../pages/DashboardPage';

setDefaultTimeout(60000);

Given('the user is on the login page', async function () {
    this.loginPage = new LoginPage(this.page);
    await this.loginPage.goto();
});

Given('the user has an account with email {string}', async function (email: string) {
    // Setup: create user in database (or mock)
    this.testEmail = email;
});

When('the user enters email {string}', async function (email: string) {
    await this.loginPage.fillEmail(email);
});

When('the user enters password {string}', async function (password: string) {
    await this.loginPage.fillPassword(password);
});

When('the user clicks the submit button', async function () {
    await this.loginPage.clickSubmit();
});

Then('the user should be redirected to the dashboard', async function () {
    this.dashboardPage = new DashboardPage(this.page);
    await expect(this.page).toHaveURL(/.*dashboard/);
});

Then('the user should see a welcome message {string}', async function (message: string) {
    await this.dashboardPage.expectWelcomeMessage(message);
});

Then('the user should see an error message {string}', async function (errorMessage: string) {
    await this.loginPage.expectErrorMessage(errorMessage);
});

Then('the user should remain on the login page', async function () {
    await expect(this.page).toHaveURL(/.*login/);
});
```

---

## World (Context Compartido)

**features/support/world.ts:**
```typescript
import { setWorldConstructor, World, IWorldOptions } from '@cucumber/cucumber';
import { Browser, BrowserContext, Page, chromium } from '@playwright/test';

export class CustomWorld extends World {
    browser!: Browser;
    context!: BrowserContext;
    page!: Page;

    constructor(options: IWorldOptions) {
        super(options);
    }

    async init() {
        this.browser = await chromium.launch({
            headless: process.env.HEADLESS !== 'false'
        });

        this.context = await this.browser.newContext();
        this.page = await this.context.newPage();
    }

    async cleanup() {
        await this.page?.close();
        await this.context?.close();
        await this.browser?.close();
    }
}

setWorldConstructor(CustomWorld);
```

---

## Hooks

**features/support/hooks.ts:**
```typescript
import { Before, After, BeforeAll, AfterAll, Status } from '@cucumber/cucumber';
import { CustomWorld } from './world';

// Before all scenarios
BeforeAll(async function () {
    console.log('Starting test suite...');
});

// Before each scenario
Before(async function (this: CustomWorld) {
    await this.init();
});

// After each scenario
After(async function (this: CustomWorld, { result }) {
    // Screenshot on failure
    if (result?.status === Status.FAILED) {
        const screenshot = await this.page.screenshot({
            path: `reports/screenshots/${Date.now()}.png`
        });
        this.attach(screenshot, 'image/png');
    }

    await this.cleanup();
});

// After all scenarios
AfterAll(async function () {
    console.log('Test suite completed');
});

// Tagged hooks
Before({ tags: '@slow' }, async function () {
    console.log('Running slow test...');
});

Before({ tags: '@authentication' }, async function (this: CustomWorld) {
    // Auto-login for @authentication tagged scenarios
    await this.page.goto('/login');
    await this.page.fill('#email', 'user@test.com');
    await this.page.fill('#password', 'password123');
    await this.page.click('button[type="submit"]');
});
```

---

## Data Tables

**Feature:**
```gherkin
Scenario: Register user with details
  When the user registers with the following details:
    | field       | value           |
    | firstName   | John            |
    | lastName    | Doe             |
    | email       | john@test.com   |
    | password    | SecurePass123!  |
  Then the user should be registered successfully
```

**Step Definition:**
```typescript
When('the user registers with the following details:', async function (dataTable) {
    const data = dataTable.rowsHash();

    await this.registerPage.fillFirstName(data.firstName);
    await this.registerPage.fillLastName(data.lastName);
    await this.registerPage.fillEmail(data.email);
    await this.registerPage.fillPassword(data.password);
    await this.registerPage.clickSubmit();
});
```

**Arrays en Data Tables:**
```gherkin
Scenario: Add multiple products to cart
  When the user adds the following products:
    | name      | quantity |
    | Laptop    | 1        |
    | Mouse     | 2        |
    | Keyboard  | 1        |
  Then the cart should contain 3 items
```

```typescript
When('the user adds the following products:', async function (dataTable) {
    const products = dataTable.hashes(); // Array of objects

    for (const product of products) {
        await this.productPage.addToCart(product.name, parseInt(product.quantity));
    }
});
```

---

## Tags y Filtering

**Feature con tags:**
```gherkin
@smoke @critical
Feature: User Authentication

  @positive
  Scenario: Successful login
    # ...

  @negative @slow
  Scenario: Failed login
    # ...
```

**Ejecutar por tags:**
```bash
# Run only @smoke tests
npx cucumber-js --tags "@smoke"

# Run @smoke but not @slow
npx cucumber-js --tags "@smoke and not @slow"

# Run @critical or @smoke
npx cucumber-js --tags "@critical or @smoke"
```

---

## Scenario Outline (Data-Driven)

```gherkin
Scenario Outline: Search for products
  When the user searches for "<query>"
  Then the results should show "<expectedCount>" products
  And the first result should be "<firstProduct>"

  Examples:
    | query   | expectedCount | firstProduct  |
    | laptop  | 15            | MacBook Pro   |
    | mouse   | 8             | Logitech MX   |
    | monitor | 12            | Dell UltraWide |

  @slow
  Examples: Slow searches
    | query      | expectedCount | firstProduct |
    | smartphone | 50            | iPhone 15    |
```

---

## Custom Parameter Types

```typescript
// features/support/parameterTypes.ts
import { defineParameterType } from '@cucumber/cucumber';

defineParameterType({
    name: 'user',
    regexp: /admin|customer|guest/,
    transformer: (role: string) => {
        const users = {
            admin: { email: 'admin@test.com', password: 'admin123' },
            customer: { email: 'user@test.com', password: 'user123' },
            guest: { email: 'guest@test.com', password: 'guest123' }
        };
        return users[role as keyof typeof users];
    }
});

// Usage in feature
// When the user logs in as {user}
```

**Step definition:**
```typescript
When('the user logs in as {user}', async function (user: { email: string, password: string }) {
    await this.loginPage.login(user.email, user.password);
});
```

---

## Reporting

### HTML Report

```javascript
// cucumber.js
format: ['html:reports/cucumber-report.html']
```

### JSON Report

```javascript
format: ['json:reports/cucumber-report.json']
```

### Multiple Reporters

```bash
npx cucumber-js \
  --format progress \
  --format html:reports/cucumber.html \
  --format json:reports/cucumber.json
```

### Screenshot on Failure

```typescript
After(async function (this: CustomWorld, { result, pickle }) {
    if (result?.status === Status.FAILED) {
        const screenshot = await this.page.screenshot();
        this.attach(screenshot, 'image/png');

        // También puedes adjuntar logs
        const logs = await this.page.evaluate(() => {
            return window.console.logs; // Si los guardas
        });
        this.attach(JSON.stringify(logs), 'application/json');
    }
});
```

---

## Best Practices

### ✅ DO

```gherkin
# Lenguaje del dominio (negocio)
Given the user is logged in
When the user adds a product to cart
Then the cart should show 1 item

# Específico y testable
Then the user should see "Product added successfully"
And the cart count should be 1

# Scenario Outline para variaciones
Scenario Outline: Login with different users
  When the user logs in as "<role>"
  Then the user should see "<dashboard>"

# Tags para organización
@smoke @authentication
Scenario: Login

# Background para setup común
Background:
  Given the database is clean
  And the user exists in the system
```

### ❌ DON'T

```gherkin
# ❌ Detalles de implementación
When the user clicks on button with id "#submit-btn"
And the user waits for 2 seconds

# ❌ Scenarios muy largos (> 10 steps)
Given ...
When ...
And ...
And ...
And ...
And ... (15 more lines)

# ❌ Steps muy genéricos
When the user does something
Then something happens

# ❌ Multiple assertions en Then
Then the user should see "Welcome"
And the user should see "Dashboard"
And the user should see "Profile"
And the user should see "Settings"
# ❌ MEJOR: Then the user should see the dashboard

# ❌ Logic en Gherkin
# No: if/else, loops, calculaciones
```

---

## Integration con CI/CD

**GitHub Actions:**
```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  e2e:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run Cucumber tests
        run: npm run test:e2e

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: cucumber-reports
          path: reports/
```

**package.json:**
```json
{
  "scripts": {
    "test:e2e": "cucumber-js",
    "test:e2e:smoke": "cucumber-js --tags '@smoke'",
    "test:e2e:headed": "HEADLESS=false cucumber-js"
  }
}
```

---

## Parallel Execution

```javascript
// cucumber.js
module.exports = {
    default: {
        parallel: 4, // 4 workers
        retry: 2,    // Retry failed scenarios 2 times
        retryTagFilter: '@flaky'
    }
};
```

---

## 🔄 Auto-Mantenimiento con Context7

**Library tracked:** `/cucumber/cucumber-js`

**Actualización automática:**
```
mcp__context7__resolve-library-id: libraryName="Cucumber JavaScript"
mcp__context7__query-docs: libraryId="/cucumber/cucumber-js", query="latest Cucumber.js features and Playwright integration"
```

**Qué se actualiza:**
- ✅ Nuevas features de Gherkin
- ✅ Breaking changes en API
- ✅ Nuevos parameter types
- ✅ Mejoras en reporting
- ✅ Parallel execution patterns

**Qué se preserva:**
- ✅ Step definitions existentes
- ✅ Custom parameter types
- ✅ World configuration
- ✅ Hooks y setup

**Frecuencia:** Automática cuando detecta nueva versión

**Última sync:** 2026-02-04
**Versión tracked:** Cucumber.js 10.x

---

*Organismo viviente: Context7 + Experiencia comunitaria + Tu uso*
