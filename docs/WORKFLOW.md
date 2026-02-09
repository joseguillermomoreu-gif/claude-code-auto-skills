# Workflow de Desarrollo - claude-code-auto-skills

> **Versión**: 1.0.0
> **Última actualización**: 2026-02-09

Este documento describe el workflow de desarrollo para claude-code-auto-skills, incluyendo gitflow, convenciones de branches, conventional commits, TDD para scripts bash, y proceso de releases.

---

## 📋 Tabla de Contenidos

1. [Gitflow](#gitflow)
2. [Branch Naming Conventions](#branch-naming-conventions)
3. [Conventional Commits](#conventional-commits)
4. [TDD para Scripts Bash](#tdd-para-scripts-bash)
5. [CI/CD](#cicd)
6. [Proceso de Release](#proceso-de-release)
7. [Ejemplos Prácticos](#ejemplos-prácticos)

---

## 🌳 Gitflow

Usamos **Gitflow completo** con dos ramas principales permanentes:

```
master (producción)
  ↑
  └─ release/* branches
       ↑
       └─ develop (integración)
            ↑
            ├─ feature/* (nuevas features)
            ├─ docs/* (documentación)
            └─ (otros tipos)

hotfix/* (urgentes desde master)
  ↓
master (merge directo)
  ↓
develop (back-merge automático)
```

### **Ramas Principales**

#### `master`
- Rama de **producción**
- Siempre estable y funcional
- Solo recibe merges de `release/*` y `hotfix/*`
- **Protegida**: No push directo, solo via Pull Request
- Cada merge a master = release automática

#### `develop`
- Rama de **desarrollo/integración**
- Recibe merges de `feature/*`, `docs/*`, etc.
- Puede tener features a medias
- Base para crear nuevas features

### **Ramas Temporales**

#### `feature/*` (desde develop)
- Nuevas features o mejoras
- Se crean desde `develop`
- Se mergean a `develop` via PR
- Se eliminan después del merge

#### `hotfix/*` (desde master)
- Bugs urgentes en producción
- Se crean desde `master`
- Se mergean a `master` via PR
- Se hace back-merge automático a `develop`
- Se eliminan después del merge

#### `release/*` (desde develop)
- Preparación de release
- Se crean desde `develop`
- Ajustes finales, changelog, versión
- Se mergean a `master` via PR
- Se hace back-merge automático a `develop`
- Se eliminan después del merge

#### `docs/*` (desde develop)
- Cambios solo de documentación
- Misma regla que `feature/*`

---

## 🏷️ Branch Naming Conventions

**Formato obligatorio**: `{tipo}/t_{numero}_{descripcion}`

Donde:
- `{tipo}`: feature, hotfix, release, docs
- `{numero}`: Número de issue de GitHub (sin #)
- `{descripcion}`: Descripción corta en snake_case

### **Ejemplos:**

```bash
# Features (desde develop)
feature/t_01_expand_python_skill
feature/t_06_add_django_skill
feature/t_07_add_docker_skill
feature/t_13_cli_helper

# Hotfixes (desde master)
hotfix/t_25_fix_install_symlink
hotfix/t_32_update_sh_crash

# Releases (desde develop)
release/v1.3.0
release/v2.0.0

# Documentación (desde develop)
docs/t_02_add_architecture_md
docs/t_05_update_workflow
```

### **Beneficios:**

- ✅ Trazabilidad automática (branch → issue)
- ✅ GitHub linkea automáticamente en PRs
- ✅ Fácil identificar qué issue trabaja cada branch
- ✅ Orden y consistencia

---

## 💬 Conventional Commits

Usamos **Conventional Commits** para mensajes de commit consistentes y versionado automático.

### **Formato:**

```
<tipo>[scope opcional]: <descripción>

[cuerpo opcional]

[footer opcional]
```

### **Tipos de Commit:**

| Tipo | Descripción | Bump de Versión | Ejemplo |
|------|-------------|-----------------|---------|
| `feat` | Nueva feature | **Minor** (1.2.3 → 1.3.0) | `feat: add django.md skill` |
| `fix` | Bug fix | **Patch** (1.2.3 → 1.2.4) | `fix: install.sh symlink creation` |
| `docs` | Solo documentación | Ninguno | `docs: add ARCHITECTURE.md` |
| `style` | Formato, espacios | Ninguno | `style: fix indentation in install.sh` |
| `refactor` | Refactorización | Ninguno | `refactor: simplify update.sh logic` |
| `test` | Añadir/modificar tests | Ninguno | `test: add tests for install.sh` |
| `chore` | Tareas de mantenimiento | Ninguno | `chore: update dependencies` |
| `perf` | Mejora de performance | **Patch** | `perf: optimize skill loading` |

### **Breaking Changes:**

Añade `!` después del tipo para indicar breaking change (bump **Major**):

```bash
feat!: change skill format to JSON  # 1.2.3 → 2.0.0
fix!: remove deprecated install flag  # 1.2.3 → 2.0.0
```

### **Scope (Opcional):**

Añade contexto específico:

```bash
feat(cli): add claude-skills command
fix(update): handle git conflicts gracefully
docs(readme): update installation steps
test(install): add backup creation test
```

### **Ejemplos Completos:**

```bash
# Feature simple
feat: add django.md skill

# Feature con scope
feat(skills): add docker.md with multi-stage builds

# Fix simple
fix: install.sh creates backup before overwriting

# Fix con scope y descripción extendida
fix(update): handle git conflicts during pull

When update.sh does git pull and there are conflicts,
the script now stashes local changes and retries.

Fixes #42

# Breaking change
feat!: change skill metadata format

Skills now require version field in YAML frontmatter.
This breaks compatibility with skills v1.x.

BREAKING CHANGE: Skills without version field will fail to load.
```

---

## 🧪 TDD para Scripts Bash

**Regla estricta**: Si modificas cualquier script `.sh`, **DEBES** usar TDD (Test-Driven Development).

### **Proceso TDD (Red-Green-Refactor):**

```
1. RED    → Escribe test que falla
2. GREEN  → Implementa feature mínima para que pase
3. REFACTOR → Mejora código manteniendo tests verdes
```

### **Scripts que Requieren TDD:**

- ✅ `install.sh`
- ✅ `update.sh`
- ✅ `uninstall.sh`
- ✅ `init-repo.sh`
- ✅ Cualquier nuevo script `.sh`

### **Framework de Testing:**

Usamos **bats** (Bash Automated Testing System):

```bash
# Instalar bats
npm install -g bats

# Ejecutar todos los tests
./tests/run_tests.sh

# Ejecutar test específico
./tests/run_tests.sh test_install.sh

# Modo verbose
./tests/run_tests.sh -v
```

### **Estructura de Tests:**

```
tests/
├── run_tests.sh           # Ejecutor principal
├── test_helpers.sh        # Funciones helper
├── test_install.sh        # Tests de install.sh
├── test_update.sh         # Tests de update.sh
└── README.md              # Documentación de testing
```

### **Ejemplo de Test (bats):**

```bash
#!/usr/bin/env bats

# tests/test_install.sh

load test_helpers

@test "install.sh creates symlinks in ~/.claude/skills/" {
    # Arrange
    setup_test_env

    # Act
    run ./install.sh

    # Assert
    assert_success
    assert_file_exists "$HOME/.claude/skills/python.md"
    assert_is_symlink "$HOME/.claude/skills/python.md"
}

@test "install.sh creates backup if previous installation exists" {
    # Arrange
    setup_test_env
    create_fake_installation

    # Act
    run ./install.sh

    # Assert
    assert_success
    assert_directory_exists "$HOME/.claude/backups/claude-skills-*"
}

@test "install.sh validates git is installed" {
    # Arrange
    setup_test_env
    mock_command git "exit 1"  # Simula git no disponible

    # Act
    run ./install.sh

    # Assert
    assert_failure
    assert_output --partial "git is required"
}
```

### **Funciones Helper Disponibles:**

Ver `tests/test_helpers.sh` para todas las funciones:

```bash
# Setup/Teardown
setup_test_env()           # Crea entorno de test aislado
teardown_test_env()        # Limpia después del test

# Assertions
assert_success()           # Verifica exit code 0
assert_failure()           # Verifica exit code != 0
assert_file_exists()       # Verifica archivo existe
assert_directory_exists()  # Verifica directorio existe
assert_is_symlink()        # Verifica es symlink
assert_output()            # Verifica output del comando

# Mocking
mock_command()             # Mockea comando externo
restore_command()          # Restaura comando original
```

### **Workflow TDD Completo:**

```bash
# 1. Crear issue en GitHub (#42: "Add backup validation to install.sh")

# 2. Crear branch
git checkout develop
git pull
git checkout -b feature/t_42_add_backup_validation

# 3. RED - Escribir test que falla
vim tests/test_install.sh
# Añadir test_install_validates_backup_integrity()

./tests/run_tests.sh
# ❌ FAIL: test_install_validates_backup_integrity

# 4. GREEN - Implementar feature mínima
vim install.sh
# Añadir lógica de validación de backup

./tests/run_tests.sh
# ✅ PASS: test_install_validates_backup_integrity

# 5. REFACTOR - Mejorar código
vim install.sh
# Refactorizar lógica, extraer función validate_backup()

./tests/run_tests.sh
# ✅ PASS: test_install_validates_backup_integrity

# 6. Commit con conventional commit
git add tests/test_install.sh install.sh
git commit -m "feat: add backup validation to install.sh

- Validates backup integrity before proceeding
- Adds validate_backup() helper function
- Tests ensure backup is valid before overwriting

Fixes #42"

# 7. Push y crear PR
git push -u origin feature/t_42_add_backup_validation
gh pr create --base develop --title "feat: add backup validation to install.sh" --body "Closes #42"

# 8. CI ejecuta tests automáticamente
# GitHub Actions → tests/run_tests.sh → ✅ o ❌

# 9. Si CI pasa → Merge a develop
gh pr merge --squash
```

---

## 🤖 CI/CD

### **Continuous Integration (CI)**

Ejecuta en **cada Pull Request** a `master` o `develop`:

```yaml
# .github/workflows/ci.yml

✅ ShellCheck (linter para bash)
✅ Bash syntax check (bash -n)
✅ Run tests (./tests/run_tests.sh)
✅ Validate conventional commits format
```

**Resultado**: PR solo puede mergearse si CI pasa (✅ verde).

### **Continuous Deployment (CD)**

Ejecuta **automáticamente** al merge a `master`:

```yaml
# .github/workflows/release.yml

1. Analiza commits desde última release
2. Calcula nueva versión (semver)
3. Crea tag (v1.3.0)
4. Genera CHANGELOG.md automático
5. Crea GitHub Release
6. Back-merge master → develop
```

**Resultado**: Release publicada en GitHub sin intervención manual.

### **Logs de CI:**

Ver logs en GitHub:
```
https://github.com/joseguillermomoreu-gif/claude-code-auto-skills/actions
```

### **Ejecutar CI Localmente (antes de push):**

```bash
# ShellCheck
shellcheck *.sh

# Syntax check
bash -n install.sh

# Tests
./tests/run_tests.sh

# Validar commit message
echo "feat: add django skill" | npx commitlint --verbose
```

---

## 🚀 Proceso de Release

### **Release Normal (de develop a master):**

```bash
# 1. Asegurar develop está actualizado
git checkout develop
git pull

# 2. Crear branch de release
git checkout -b release/v1.3.0

# 3. Preparar release (opcional)
# - Actualizar versión en install.sh si es necesario
# - Últimos ajustes de documentación
# - Review final

# 4. Commit de preparación (opcional)
git commit -am "chore: prepare release v1.3.0"

# 5. Push y crear PR a master
git push -u origin release/v1.3.0
gh pr create --base master --title "Release v1.3.0" --body "Release version 1.3.0 with new features"

# 6. CI valida (tests pasan)

# 7. Merge a master (via GitHub UI o CLI)
gh pr merge --squash

# 8. GitHub Actions ejecuta automáticamente:
#    - Calcula versión → v1.3.0
#    - Crea tag v1.3.0
#    - Genera CHANGELOG.md
#    - Crea GitHub Release
#    - Back-merge master → develop

# 9. Limpiar branch local
git checkout develop
git pull  # Ahora tiene el back-merge de master
git branch -d release/v1.3.0
```

### **Hotfix (urgente desde master):**

```bash
# 1. Crear hotfix desde master
git checkout master
git pull
git checkout -b hotfix/t_42_fix_critical_bug

# 2. RED - Escribir test que falla
vim tests/test_install.sh
./tests/run_tests.sh  # ❌ FAIL

# 3. GREEN - Fix bug
vim install.sh
./tests/run_tests.sh  # ✅ PASS

# 4. Commit
git commit -am "fix: critical bug in install.sh symlink creation

Fixes #42"

# 5. Push y crear PR a master
git push -u origin hotfix/t_42_fix_critical_bug
gh pr create --base master --title "fix: critical bug in install.sh" --body "Fixes #42"

# 6. CI valida

# 7. Merge a master
gh pr merge --squash

# 8. GitHub Actions:
#    - Release v1.2.4 (patch bump)
#    - Back-merge master → develop

# 9. Limpiar
git checkout master
git pull
git branch -d hotfix/t_42_fix_critical_bug
```

### **Versionado Semántico Automático:**

GitHub Actions usa conventional commits para determinar el bump:

| Commits desde última release | Nueva Versión | Tipo Bump |
|------------------------------|---------------|-----------|
| `fix: bug in install.sh` | 1.2.3 → **1.2.4** | Patch |
| `feat: add django skill` | 1.2.3 → **1.3.0** | Minor |
| `feat!: breaking change` | 1.2.3 → **2.0.0** | Major |
| `docs: update README` | 1.2.3 → **1.2.3** | No bump |

### **CHANGELOG Automático:**

Se genera en cada release:

```markdown
## [1.3.0] - 2026-02-09

### Features
- feat: add django.md skill (#6)
- feat: add docker.md skill (#7)
- feat(cli): add claude-skills command (#13)

### Bug Fixes
- fix: install.sh symlink creation (#42)
- fix(update): handle git conflicts (#45)

### Documentation
- docs: add ARCHITECTURE.md (#2)
- docs: update WORKFLOW.md (#5)
```

---

## 📚 Ejemplos Prácticos

### **Ejemplo 1: Añadir Nueva Feature (skill)**

**Issue**: #6 - Nuevo skill: django.md

```bash
# 1. Checkout desde develop
git checkout develop
git pull

# 2. Crear branch siguiendo convención
git checkout -b feature/t_06_add_django_skill

# 3. Crear skill
vim skills/django.md
# ... escribir contenido ...

# 4. Actualizar README
vim README.md
# Añadir django.md a la lista de skills

# 5. Tests (si aplica - en este caso no, es .md)

# 6. Commit con conventional commit
git add skills/django.md README.md
git commit -m "feat: add django.md skill

Covers Django 5.x and FastAPI with:
- ORM patterns and comparisons with Symfony
- REST API examples
- Testing with pytest-django
- Naming conventions

Closes #6"

# 7. Push y crear PR
git push -u origin feature/t_06_add_django_skill
gh pr create --base develop \
  --title "feat: add django.md skill" \
  --body "Implements #6

New skill covering Django and FastAPI for backend Python development.

**Changes:**
- Added skills/django.md (~600 lines)
- Updated README.md with new skill
- Updated skills/README.md"

# 8. CI valida (shellcheck, syntax)

# 9. Merge a develop
gh pr merge --squash

# 10. Limpiar
git checkout develop
git pull
git branch -d feature/t_06_add_django_skill
```

### **Ejemplo 2: Modificar Script con TDD**

**Issue**: #3 - Tests automatizados para install.sh

```bash
# 1. Checkout desde develop
git checkout develop
git pull
git checkout -b feature/t_03_tests_install_sh

# 2. RED - Escribir test que falla
vim tests/test_install.sh

@test "install.sh creates symlinks" {
    setup_test_env
    run ./install.sh
    assert_success
    assert_is_symlink "$HOME/.claude/skills/python.md"
}

./tests/run_tests.sh
# ❌ FAIL (test no existe todavía)

# 3. GREEN - Implementar solo lo necesario
# (en este caso install.sh ya existe, solo añadimos tests)

# 4. Verificar test pasa
./tests/run_tests.sh
# ✅ PASS

# 5. Añadir más tests (repetir red-green)
vim tests/test_install.sh

@test "install.sh creates backup" { ... }
@test "install.sh validates dependencies" { ... }

# 6. Commit
git add tests/test_install.sh
git commit -m "test: add comprehensive tests for install.sh

Covers:
- Symlink creation
- Backup creation
- Dependency validation
- Error handling

Implements #3"

# 7. Push y PR
git push -u origin feature/t_03_tests_install_sh
gh pr create --base develop --title "test: add tests for install.sh" --body "Closes #3"

# 8. CI valida (ejecuta los nuevos tests)

# 9. Merge
gh pr merge --squash
```

### **Ejemplo 3: Hotfix Urgente**

**Issue**: #42 - Critical bug: install.sh fails on fresh system

```bash
# 1. Desde master (no develop)
git checkout master
git pull
git checkout -b hotfix/t_42_install_fresh_system

# 2. RED - Escribir test que reproduce el bug
vim tests/test_install.sh

@test "install.sh works on fresh system without ~/.claude" {
    setup_test_env
    rm -rf "$HOME/.claude"  # Simular sistema fresco
    run ./install.sh
    assert_success
}

./tests/run_tests.sh
# ❌ FAIL (reproduce el bug)

# 3. GREEN - Fix bug
vim install.sh

# Añadir:
mkdir -p "$HOME/.claude/skills"  # Crear directorio si no existe

./tests/run_tests.sh
# ✅ PASS

# 4. Commit
git add install.sh tests/test_install.sh
git commit -m "fix: install.sh creates ~/.claude directory if missing

Bug occurred on fresh systems without existing ~/.claude directory.
Now creates parent directory before symlinking.

Fixes #42"

# 5. Push y PR a master (no develop)
git push -u origin hotfix/t_42_install_fresh_system
gh pr create --base master \
  --title "fix: install.sh on fresh system" \
  --body "Critical hotfix for #42"

# 6. CI valida

# 7. Merge a master
gh pr merge --squash

# 8. GitHub Actions:
#    - Release v1.2.4 (patch bump)
#    - Tag v1.2.4
#    - Changelog actualizado
#    - Back-merge a develop

# 9. Verificar
git checkout master
git pull
git log --oneline -5
git tag  # Debe aparecer v1.2.4
```

---

## 🎯 Checklist Rápido

### **Antes de Empezar una Tarea:**

- [ ] Issue existe en GitHub
- [ ] Asignado a ti
- [ ] Label `refinement-needed` removido (tarea refinada)
- [ ] Entiendes qué hacer y por qué

### **Durante el Desarrollo:**

- [ ] Branch creado con formato correcto: `feature/t_XX_descripcion`
- [ ] Si modificas `.sh`: TDD estricto (red-green-refactor)
- [ ] Tests ejecutados localmente y pasan: `./tests/run_tests.sh`
- [ ] ShellCheck ejecutado: `shellcheck *.sh`
- [ ] Commits siguen conventional commits

### **Antes de Push:**

- [ ] Tests pasan localmente
- [ ] ShellCheck sin warnings
- [ ] Commits descriptivos y concisos
- [ ] Documentación actualizada si es necesario

### **Crear Pull Request:**

- [ ] PR a branch correcta (develop o master)
- [ ] Título sigue conventional commits
- [ ] Descripción clara con contexto
- [ ] Referencia al issue: "Closes #XX"
- [ ] CI pasa (verde)

### **Después del Merge:**

- [ ] Branch local eliminada: `git branch -d feature/t_XX_xxx`
- [ ] Checkout a develop/master y pull: `git checkout develop && git pull`

---

## 📞 Soporte

**Dudas sobre el workflow?**
- Revisa este documento primero
- Revisa ejemplos prácticos arriba
- Crea issue con label `question`

**Reportar problemas del workflow:**
- Issue con label `workflow`
- Sugerencias de mejora bienvenidas

---

**Última actualización**: 2026-02-09
**Autor**: José Guillermo Moreu
**Versión**: 1.0.0
