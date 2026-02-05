# GitHub Actions - CI/CD

> **Audiencia**: Desarrolladores usando GitHub para CI/CD
> **Última actualización**: 2026-02-05
> **Enfoque**: Workflows, automatización, best practices

## Conceptos Fundamentales

### ¿Qué es GitHub Actions?

**GitHub Actions** es la plataforma de CI/CD nativa de GitHub que permite:
- Automatizar workflows de build, test y deploy
- Ejecutar código en respuesta a eventos (push, PR, issues, etc.)
- Reutilizar actions de la comunidad
- Ejecutar en runners Linux, Windows, macOS

### Conceptos Clave

```yaml
Workflow: Archivo .yml que define el proceso automatizado
├─ Events: Trigger que inicia el workflow (push, pull_request, schedule, etc.)
├─ Jobs: Tareas independientes que se ejecutan en paralelo o secuencialmente
│  └─ Steps: Pasos individuales dentro de un job (actions o comandos shell)
└─ Runners: Máquinas que ejecutan los jobs (github-hosted o self-hosted)

Actions: Bloques reutilizables de código
├─ actions/checkout@v4: Clonar repositorio
├─ actions/setup-node@v4: Instalar Node.js
└─ actions/cache@v4: Cachear dependencias
```

---

## Estructura Básica de un Workflow

### Anatomía de un archivo .github/workflows/ci.yml

```yaml
name: CI Pipeline  # Nombre del workflow (visible en GitHub UI)

# Eventos que disparan el workflow
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:  # Permite ejecutar manualmente

# Variables de entorno globales
env:
  NODE_VERSION: '20.x'

# Jobs a ejecutar
jobs:
  # Job ID (debe ser único)
  build:
    name: Build and Test  # Nombre legible
    runs-on: ubuntu-latest  # Runner a usar

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test
```

---

## Patrones Comunes

### 1. Build Matrix (Múltiples Versiones)

```yaml
name: Test Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}

    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [18.x, 20.x, 22.x]
        # Excluir combinaciones específicas (opcional)
        exclude:
          - os: macos-latest
            node-version: 18.x

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}

      - run: npm ci
      - run: npm test
```

### 2. Caché de Dependencias

```yaml
# PHP/Composer
- name: Cache Composer dependencies
  uses: actions/cache@v4
  with:
    path: vendor
    key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
    restore-keys: |
      ${{ runner.os }}-composer-

- name: Install dependencies
  run: composer install --no-progress --prefer-dist

# Node.js/npm (integrado en setup-node)
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20.x'
    cache: 'npm'  # Automático

# Python/pip
- name: Cache pip dependencies
  uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}

# Docker layers
- name: Cache Docker layers
  uses: actions/cache@v4
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-
```

### 3. Condicionales y Expresiones

```yaml
steps:
  # Ejecutar solo en branch main
  - name: Deploy to production
    if: github.ref == 'refs/heads/main'
    run: ./deploy.sh

  # Ejecutar solo en PRs
  - name: Comment on PR
    if: github.event_name == 'pull_request'
    uses: actions/github-script@v7
    with:
      script: |
        github.rest.issues.createComment({
          issue_number: context.issue.number,
          owner: context.repo.owner,
          repo: context.repo.repo,
          body: '✅ Tests passed!'
        })

  # Ejecutar solo si tests pasaron
  - name: Upload coverage
    if: success()  # También: failure(), always(), cancelled()
    uses: codecov/codecov-action@v4
```

### 4. Jobs Dependientes

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run build

      # Guardar artefactos para otros jobs
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  test:
    needs: build  # Espera a que build termine
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Descargar artefactos del job anterior
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/

      - run: npm test

  deploy:
    needs: [build, test]  # Espera a ambos
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying..."
```

### 5. Secrets y Variables de Entorno

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

    env:
      # Variable de entorno pública
      ENVIRONMENT: production

    steps:
      - uses: actions/checkout@v4

      # Usar secreto (definido en Settings > Secrets)
      - name: Deploy to AWS
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          aws s3 sync ./dist s3://my-bucket

      # Usar variable de repositorio
      - name: Use repo variable
        env:
          API_URL: ${{ vars.API_URL }}
        run: echo "API URL: $API_URL"
```

---

## Ejemplos Completos por Stack

### PHP/Symfony con PHPUnit y PHPStan

```yaml
name: PHP CI

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        php-version: ['8.2', '8.3']

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP ${{ matrix.php-version }}
        uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php-version }}
          extensions: mbstring, pdo_pgsql
          coverage: xdebug
          tools: composer:v2

      - name: Cache Composer dependencies
        uses: actions/cache@v4
        with:
          path: vendor
          key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}

      - name: Install dependencies
        run: composer install --no-progress --prefer-dist

      - name: Run PHPStan
        run: vendor/bin/phpstan analyse src --level=9

      - name: Run PHPUnit
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
        run: vendor/bin/phpunit --coverage-clover coverage.xml

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.xml
```

### Node.js/TypeScript con Playwright

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  test:
    timeout-minutes: 60
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20.x'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run Playwright tests
        run: npx playwright test

      - name: Upload Playwright report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

### Python con Poetry y Pytest

```yaml
name: Python CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: ['3.11', '3.12']

    steps:
      - uses: actions/checkout@v4

      - name: Setup Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install Poetry
        uses: snok/install-poetry@v1
        with:
          version: 1.7.1
          virtualenvs-create: true
          virtualenvs-in-project: true

      - name: Cache dependencies
        uses: actions/cache@v4
        with:
          path: .venv
          key: venv-${{ runner.os }}-${{ matrix.python-version }}-${{ hashFiles('**/poetry.lock') }}

      - name: Install dependencies
        run: poetry install --no-interaction

      - name: Run tests
        run: poetry run pytest --cov=src --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
```

### Docker Build y Push

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## Workflows Avanzados

### 1. Monorepo con Path Filters

```yaml
name: Monorepo CI

on:
  pull_request:
    paths:
      - 'packages/**'
      - 'apps/**'

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      backend: ${{ steps.filter.outputs.backend }}
      frontend: ${{ steps.filter.outputs.frontend }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            backend:
              - 'packages/backend/**'
            frontend:
              - 'apps/frontend/**'

  backend:
    needs: changes
    if: needs.changes.outputs.backend == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd packages/backend && npm test

  frontend:
    needs: changes
    if: needs.changes.outputs.frontend == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd apps/frontend && npm test
```

### 2. Deployment con Environments

```yaml
name: Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        run: ./deploy.sh staging

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        run: ./deploy.sh production
```

### 3. Scheduled Workflows (Cron)

```yaml
name: Nightly Build

on:
  schedule:
    # Cron: minuto hora día mes día-semana (UTC)
    - cron: '0 2 * * *'  # 2 AM UTC cada día
  workflow_dispatch:  # También manual

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run nightly tests
        run: npm run test:integration
```

---

## Reusable Workflows

### Definir workflow reutilizable

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string
      working-directory:
        required: false
        type: string
        default: '.'
    secrets:
      NPM_TOKEN:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}

      - name: Install and test
        working-directory: ${{ inputs.working-directory }}
        run: |
          npm ci
          npm test
```

### Usar workflow reutilizable

```yaml
# .github/workflows/ci.yml
name: CI

on: [push]

jobs:
  test-backend:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20.x'
      working-directory: './backend'
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}

  test-frontend:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20.x'
      working-directory: './frontend'
```

---

## Best Practices

### 1. Optimización de Velocidad

```yaml
# ✅ Usar caché agresivamente
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

# ✅ Jobs en paralelo por defecto
jobs:
  lint:
    runs-on: ubuntu-latest
  test:
    runs-on: ubuntu-latest
  # Corren en paralelo a menos que uses "needs"

# ✅ Usar artifacts para compartir entre jobs
- uses: actions/upload-artifact@v4
  with:
    name: build
    path: dist/
    retention-days: 1  # Solo 1 día si es temporal

# ❌ Evitar instalar dependencias innecesarias
run: npm ci --production  # Solo production dependencies
```

### 2. Seguridad

```yaml
# ✅ Usar secrets para datos sensibles
env:
  API_KEY: ${{ secrets.API_KEY }}

# ✅ Pin de versiones de actions por SHA
- uses: actions/checkout@8ade135a41bc03ea155e62e844d188df1ea18608  # v4.1.0

# ✅ Permisos mínimos
permissions:
  contents: read
  pull-requests: write

# ❌ NUNCA imprimir secretos
run: echo "Secret: ${{ secrets.API_KEY }}"  # ¡MAL!

# ✅ Evitar code injection en scripts
- name: Comment on PR
  run: |
    # ❌ Vulnerable a injection
    echo "User comment: ${{ github.event.comment.body }}"

    # ✅ Usar environment file
    echo "COMMENT<<EOF" >> $GITHUB_ENV
    echo "${{ github.event.comment.body }}" >> $GITHUB_ENV
    echo "EOF" >> $GITHUB_ENV
```

### 3. Debugging

```yaml
# Habilitar debug logging
# Configurar secrets en repo:
# ACTIONS_RUNNER_DEBUG = true
# ACTIONS_STEP_DEBUG = true

steps:
  # Ver variables disponibles
  - name: Dump context
    run: echo '${{ toJSON(github) }}'

  # SSH debugging (action externa)
  - name: Setup tmate session
    uses: mxschmitt/action-tmate@v3
    if: failure()  # Solo si falla
```

---

## GitHub Actions vs GitLab CI

| Feature | GitHub Actions | GitLab CI |
|---------|----------------|-----------|
| **Archivo** | `.github/workflows/*.yml` | `.gitlab-ci.yml` |
| **Syntax** | `jobs` > `steps` | `stages` > `jobs` |
| **Runners** | GitHub-hosted o self-hosted | GitLab-hosted o self-hosted |
| **Marketplace** | ✅ GitHub Actions Marketplace | ❌ Sin marketplace |
| **Reusabilidad** | Reusable workflows + actions | `include` + `extends` |
| **Caché** | `actions/cache` | `cache:` keyword |
| **Artifacts** | `actions/upload-artifact` | `artifacts:` keyword |

---

## Recursos y Referencias

### Documentación Oficial
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Workflow Syntax**: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- **GitHub Actions Marketplace**: https://github.com/marketplace?type=actions

### Actions Recomendadas
- **actions/checkout@v4**: Clonar repositorio
- **actions/setup-node@v4**: Setup Node.js
- **actions/cache@v4**: Caché de dependencias
- **codecov/codecov-action@v4**: Upload coverage
- **docker/build-push-action@v5**: Build y push Docker
- **peter-evans/create-pull-request@v6**: Crear PRs automáticamente

### Herramientas
- **act**: Ejecutar GitHub Actions localmente (https://github.com/nektos/act)
- **actionlint**: Linter para workflows (https://github.com/rhysd/actionlint)

---

## Auto-Mantenimiento

Este skill se mantiene actualizado consultando:
- GitHub Actions changelog
- Nuevas actions en el Marketplace
- Best practices de la comunidad

**Última revisión**: 2026-02-05
**Próxima revisión sugerida**: 2026-05-05

---

*Skill mantenido por Claude Code según preferencias de jgmoreu*
*Ver: ~/.claude/CLAUDE.md para más información del sistema de skills*
