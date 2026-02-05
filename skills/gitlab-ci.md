# GitLab CI/CD - Pipeline Configuration

> **Audiencia**: Desarrolladores usando GitLab para CI/CD
> **Última actualización**: 2026-02-05
> **Enfoque**: .gitlab-ci.yml, pipelines, best practices

## Conceptos Fundamentales

### ¿Qué es GitLab CI/CD?

**GitLab CI/CD** es la plataforma de integración y despliegue continuo integrada en GitLab que permite:
- Definir pipelines en un archivo `.gitlab-ci.yml` en el root del repo
- Ejecutar jobs en GitLab Runners (compartidos o propios)
- Automatizar build, test, deploy
- Visualizar pipelines en la UI de GitLab

### Conceptos Clave

```yaml
Pipeline: Conjunto de stages y jobs que se ejecutan automáticamente
├─ Stages: Fases del pipeline (build, test, deploy) - se ejecutan secuencialmente
├─ Jobs: Tareas dentro de un stage - se ejecutan en paralelo dentro del stage
├─ Runners: Máquinas que ejecutan los jobs (shared, group, project)
└─ Artifacts: Archivos generados que se pasan entre jobs

Variables: Variables de entorno (predefined, custom, protected)
├─ CI_COMMIT_SHA: SHA del commit
├─ CI_COMMIT_BRANCH: Nombre del branch
└─ CI_PIPELINE_ID: ID del pipeline
```

---

## Estructura Básica de .gitlab-ci.yml

### Anatomía de un Pipeline

```yaml
# Stages define el orden de ejecución
stages:
  - build
  - test
  - deploy

# Variables globales
variables:
  NODE_VERSION: "20.x"
  POSTGRES_DB: "test_db"

# Default settings para todos los jobs
default:
  image: node:20-alpine
  before_script:
    - npm ci

# Job de build
build-job:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

# Job de test
test-job:
  stage: test
  script:
    - npm test
  coverage: '/Coverage: \d+\.\d+%/'

# Job de deploy
deploy-job:
  stage: deploy
  script:
    - ./deploy.sh
  only:
    - main
  when: manual  # Requiere acción manual
```

---

## Patrones Comunes

### 1. Jobs con Diferentes Imágenes

```yaml
stages:
  - build
  - test

build-php:
  stage: build
  image: php:8.3-cli
  script:
    - composer install
    - vendor/bin/phpunit

build-node:
  stage: build
  image: node:20-alpine
  script:
    - npm ci
    - npm run build
```

### 2. Services (Contenedores Adicionales)

```yaml
test:
  stage: test
  image: php:8.3-cli

  services:
    - postgres:16
    - redis:7-alpine

  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password
    POSTGRES_HOST_AUTH_METHOD: trust

  script:
    - composer install
    - php bin/console doctrine:migrations:migrate --no-interaction
    - vendor/bin/phpunit
```

### 3. Artifacts y Dependencies

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
      - node_modules/
    expire_in: 1 day

test:
  stage: test
  dependencies:
    - build  # Solo descarga artifacts de este job
  script:
    - npm test

deploy:
  stage: deploy
  dependencies:
    - build
  script:
    - rsync -avz dist/ user@server:/var/www/
  artifacts:
    reports:
      dotenv: deploy.env  # Variables para jobs posteriores
```

### 4. Cache de Dependencias

```yaml
# Cache global
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/

# Cache por job (override)
test:
  stage: test
  cache:
    key: ${CI_COMMIT_REF_SLUG}-test
    paths:
      - vendor/
      - .composer-cache/
  script:
    - composer install --prefer-dist
    - vendor/bin/phpunit

# Cache por branch
build:
  cache:
    key:
      files:
        - package-lock.json  # Invalida cache si cambia
    paths:
      - node_modules/
  script:
    - npm ci
    - npm run build
```

### 5. Condicionales (only, except, rules)

```yaml
# Sintaxis antigua: only/except
deploy-staging:
  stage: deploy
  script: ./deploy.sh staging
  only:
    - develop
  except:
    - tags

# ✅ Sintaxis moderna: rules (recomendado)
deploy-production:
  stage: deploy
  script: ./deploy.sh production
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: manual
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: on_success

# Rules complejas
test:
  script: npm test
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: always
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: always
    - when: never  # Default: no ejecutar

# Changes: ejecutar solo si ciertos archivos cambiaron
frontend-test:
  script: npm test
  rules:
    - changes:
        - frontend/**/*
        - package.json
      when: always
```

### 6. Parallel Jobs (Matrix)

```yaml
test:
  stage: test
  parallel:
    matrix:
      - PHP_VERSION: ['8.2', '8.3']
        DB: ['mysql', 'postgres']
  image: php:${PHP_VERSION}
  services:
    - name: ${DB}:latest
      alias: database
  script:
    - composer install
    - vendor/bin/phpunit

# Resultado: 4 jobs (8.2+mysql, 8.2+postgres, 8.3+mysql, 8.3+postgres)
```

---

## Ejemplos Completos por Stack

### PHP/Symfony con Composer y PHPUnit

```yaml
stages:
  - prepare
  - test
  - deploy

variables:
  COMPOSER_CACHE_DIR: "$CI_PROJECT_DIR/.composer-cache"

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - vendor/
    - .composer-cache/

composer:
  stage: prepare
  image: composer:latest
  script:
    - composer install --prefer-dist --no-ansi --no-interaction --no-progress
  artifacts:
    paths:
      - vendor/
    expire_in: 1 hour

phpstan:
  stage: test
  image: php:8.3-cli
  dependencies:
    - composer
  script:
    - vendor/bin/phpstan analyse src --level=9

phpunit:
  stage: test
  image: php:8.3-cli
  services:
    - postgres:16
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    DATABASE_URL: "postgresql://postgres:postgres@postgres:5432/test_db?serverVersion=16&charset=utf8"
  dependencies:
    - composer
  script:
    - php bin/console doctrine:migrations:migrate --no-interaction --env=test
    - vendor/bin/phpunit --coverage-text --colors=never
  coverage: '/^\s*Lines:\s*\d+\.\d+\%/'
  artifacts:
    reports:
      junit: var/log/junit.xml
      coverage_report:
        coverage_format: cobertura
        path: var/log/cobertura.xml

deploy-production:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache openssh-client rsync
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh && chmod 700 ~/.ssh
    - ssh-keyscan $DEPLOY_HOST >> ~/.ssh/known_hosts
  script:
    - rsync -avz --delete --exclude='.env' ./ $DEPLOY_USER@$DEPLOY_HOST:/var/www/app/
    - ssh $DEPLOY_USER@$DEPLOY_HOST 'cd /var/www/app && composer install --no-dev --optimize-autoloader'
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: manual
  environment:
    name: production
    url: https://example.com
```

### Node.js/TypeScript con npm y Jest

```yaml
image: node:20-alpine

stages:
  - build
  - test
  - deploy

cache:
  key:
    files:
      - package-lock.json
  paths:
    - node_modules/
    - .npm/

.node_template: &node_template
  before_script:
    - npm ci --cache .npm --prefer-offline

build:
  <<: *node_template
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 day

lint:
  <<: *node_template
  stage: test
  script:
    - npm run lint

test:unit:
  <<: *node_template
  stage: test
  script:
    - npm run test:unit -- --coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

test:e2e:
  <<: *node_template
  stage: test
  image: mcr.microsoft.com/playwright:v1.40.0-jammy
  script:
    - npx playwright install
    - npm run test:e2e
  artifacts:
    when: always
    paths:
      - playwright-report/
    expire_in: 7 days

deploy:staging:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache curl
  script:
    - curl -X POST $WEBHOOK_URL -H "Content-Type: application/json" -d '{"ref":"$CI_COMMIT_SHA"}'
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'
  environment:
    name: staging
    url: https://staging.example.com
```

### Python con Poetry y Pytest

```yaml
image: python:3.12

stages:
  - test
  - deploy

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.pip"

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .pip
    - .venv/

before_script:
  - pip install poetry==1.7.1
  - poetry config virtualenvs.in-project true
  - poetry install --no-interaction

test:
  stage: test
  script:
    - poetry run pytest --cov=src --cov-report=xml --cov-report=term
  coverage: '/TOTAL.*\s+(\d+%)$/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

lint:
  stage: test
  script:
    - poetry run ruff check src/
    - poetry run mypy src/

deploy:
  stage: deploy
  script:
    - poetry build
    - poetry publish --username $PYPI_USERNAME --password $PYPI_PASSWORD
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
```

### Docker Build y Push a Registry

```yaml
stages:
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"

build:
  stage: build
  image: docker:24-cli
  services:
    - docker:24-dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  rules:
    - if: '$CI_COMMIT_BRANCH == "main" || $CI_COMMIT_BRANCH == "develop"'

build:tag:
  stage: build
  image: docker:24-cli
  services:
    - docker:24-dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG -t $CI_REGISTRY_IMAGE:latest .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
    - docker push $CI_REGISTRY_IMAGE:latest
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'

deploy:k8s:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context $KUBE_CONTEXT
    - kubectl set image deployment/myapp myapp=$CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
    - kubectl rollout status deployment/myapp
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: manual
```

---

## Workflows Avanzados

### 1. Includes y Templates Reutilizables

```yaml
# .gitlab/ci/templates/test.yml
.test-template:
  stage: test
  script:
    - npm ci
    - npm test
  coverage: '/Coverage: \d+\.\d+%/'

# .gitlab-ci.yml
include:
  - local: '.gitlab/ci/templates/test.yml'
  - remote: 'https://example.com/common-ci.yml'
  - template: Security/SAST.gitlab-ci.yml  # Template oficial

stages:
  - test

test:frontend:
  extends: .test-template
  variables:
    WORKING_DIR: frontend
  before_script:
    - cd $WORKING_DIR
    - npm ci

test:backend:
  extends: .test-template
  variables:
    WORKING_DIR: backend
```

### 2. Child Pipelines (Pipelines Anidados)

```yaml
# .gitlab-ci.yml (parent)
trigger-frontend:
  stage: deploy
  trigger:
    include: frontend/.gitlab-ci.yml
    strategy: depend
  rules:
    - changes:
        - frontend/**/*

trigger-backend:
  stage: deploy
  trigger:
    include: backend/.gitlab-ci.yml
  rules:
    - changes:
        - backend/**/*

# frontend/.gitlab-ci.yml (child)
stages:
  - build
  - test

build:
  stage: build
  script:
    - cd frontend && npm run build
```

### 3. Manual Gates y Environments

```yaml
deploy:staging:
  stage: deploy
  script: ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com
    on_stop: stop:staging
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'

stop:staging:
  stage: deploy
  script: ./teardown.sh staging
  environment:
    name: staging
    action: stop
  when: manual
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'

deploy:production:
  stage: deploy
  script: ./deploy.sh production
  environment:
    name: production
    url: https://example.com
    deployment_tier: production
  when: manual  # Requiere aprobación manual
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

### 4. Dynamic Child Pipelines

```yaml
generate-config:
  stage: build
  script:
    - python generate_pipeline.py > generated-config.yml
  artifacts:
    paths:
      - generated-config.yml

trigger-dynamic:
  stage: deploy
  trigger:
    include:
      - artifact: generated-config.yml
        job: generate-config
    strategy: depend
```

---

## Best Practices

### 1. Optimización de Velocidad

```yaml
# ✅ Usar cache agresivamente
cache:
  key:
    files:
      - package-lock.json
  paths:
    - node_modules/
  policy: pull-push  # Default: descargar y subir

# ✅ Policy: pull en jobs que solo leen
test:
  cache:
    policy: pull
  script:
    - npm test

# ✅ Interruptible jobs (cancelar si nuevo push)
build:
  interruptible: true
  script:
    - npm run build

# ✅ Artifacts mínimos
build:
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour  # Auto-eliminar artifacts antiguos
    exclude:
      - dist/**/*.map  # Excluir source maps

# ❌ Evitar instalar dependencias repetidas
# Mal: npm install en cada job
# Bien: npm ci una vez, compartir con artifacts o cache
```

### 2. Seguridad

```yaml
# ✅ Variables protegidas (Settings > CI/CD > Variables)
# - Marca como "Protected" para que solo estén disponibles en branches protegidos
# - Marca como "Masked" para que no se muestren en logs

deploy:
  script:
    - curl -H "Authorization: Bearer $API_TOKEN" ...
  # $API_TOKEN solo disponible en main/develop

# ✅ Usar variables de archivo para contenido largo
deploy:
  before_script:
    - echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    - chmod 600 ~/.ssh/id_rsa

# ✅ SAST/DAST integrados
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml

# ❌ NUNCA imprimir secretos
script:
  - echo "Token: $API_TOKEN"  # ¡MAL!
```

### 3. DRY (Don't Repeat Yourself)

```yaml
# ✅ Usar anchors YAML
.node-cache: &node-cache
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/

.node-install: &node-install
  before_script:
    - npm ci

build:
  <<: *node-cache
  <<: *node-install
  script:
    - npm run build

test:
  <<: *node-cache
  <<: *node-install
  script:
    - npm test

# ✅ Usar extends (más potente)
.base:
  image: node:20-alpine
  cache:
    paths:
      - node_modules/
  before_script:
    - npm ci

build:
  extends: .base
  script:
    - npm run build

test:
  extends: .base
  script:
    - npm test
```

### 4. Debugging

```yaml
# Ver todas las variables disponibles
debug:
  script:
    - export
    - echo "Branch: $CI_COMMIT_BRANCH"
    - echo "Tag: $CI_COMMIT_TAG"
    - echo "Pipeline ID: $CI_PIPELINE_ID"

# Guardar artifacts de debug
test:
  script:
    - npm test
  after_script:
    - cat /var/log/app.log
  artifacts:
    when: on_failure
    paths:
      - logs/
      - screenshots/
    expire_in: 7 days
```

---

## GitLab CI vs GitHub Actions

| Feature | GitLab CI | GitHub Actions |
|---------|-----------|----------------|
| **Archivo** | `.gitlab-ci.yml` | `.github/workflows/*.yml` |
| **Syntax** | `stages` > `jobs` | `jobs` > `steps` |
| **Paralelismo** | Jobs en mismo stage | Jobs independientes |
| **Reusabilidad** | `include` + `extends` | Reusable workflows + actions |
| **Caché** | Keyword `cache:` | Action `actions/cache` |
| **Artifacts** | Keyword `artifacts:` | Action `actions/upload-artifact` |
| **Marketplace** | ❌ Sin marketplace | ✅ GitHub Actions Marketplace |
| **Integrado** | ✅ Integrado en GitLab | ✅ Integrado en GitHub |

---

## Recursos y Referencias

### Documentación Oficial
- **GitLab CI/CD Docs**: https://docs.gitlab.com/ee/ci/
- **.gitlab-ci.yml Reference**: https://docs.gitlab.com/ee/ci/yaml/
- **CI/CD Examples**: https://docs.gitlab.com/ee/ci/examples/

### Templates Oficiales
- Auto DevOps
- SAST (Static Application Security Testing)
- Dependency Scanning
- Container Scanning
- DAST (Dynamic Application Security Testing)

### Herramientas
- **gitlab-ci-local**: Ejecutar pipelines localmente (https://github.com/firecow/gitlab-ci-local)
- **GitLab CI Linter**: Validar sintaxis (Project > CI/CD > Pipelines > CI Lint)
- **GitLab Runner**: https://docs.gitlab.com/runner/

---

## Auto-Mantenimiento

Este skill se mantiene actualizado consultando:
- GitLab CI/CD changelog
- GitLab templates oficiales
- Best practices de la comunidad

**Última revisión**: 2026-02-05
**Próxima revisión sugerida**: 2026-05-05

---

*Skill mantenido por Claude Code según preferencias de jgmoreu*
*Ver: ~/.claude/CLAUDE.md para más información del sistema de skills*
