# Testing - claude-code-auto-skills

Esta carpeta contiene los tests automatizados para los scripts bash del proyecto.

---

## 🎯 Filosofía: TDD Estricto

**Si modificas cualquier script `.sh`, DEBES usar TDD (Test-Driven Development).**

### Proceso TDD (Red-Green-Refactor):

```
1. 🔴 RED    → Escribe test que falla
2. 🟢 GREEN  → Implementa feature mínima para que pase
3. ♻️ REFACTOR → Mejora código manteniendo tests verdes
```

---

## 🚀 Quick Start

### Ejecutar Todos los Tests

```bash
./tests/run_tests.sh
```

### Ejecutar Test Específico

```bash
./tests/run_tests.sh test_install.sh
```

### Modo Verbose

```bash
./tests/run_tests.sh -v
```

---

## 📦 Instalación de Dependencias

Los tests usan **bats** (Bash Automated Testing System):

```bash
# Via npm (recomendado)
npm install -g bats

# O en Ubuntu/Debian
sudo apt-get install bats
```

---

## 📁 Estructura

```
tests/
├── run_tests.sh           # Ejecutor principal de tests
├── test_helpers.sh        # Funciones helper para tests
├── test_install.sh        # Tests para install.sh (issue #3)
├── test_update.sh         # Tests para update.sh (issue #4)
└── README.md              # Este archivo
```

---

## ✍️ Escribir Tests

### Template Básico

```bash
#!/usr/bin/env bats

# Cargar helpers
load test_helpers

# Setup que se ejecuta antes de cada test
setup() {
    setup_test_env
}

# Teardown que se ejecuta después de cada test
teardown() {
    teardown_test_env
}

# Test básico
@test "descripción del test" {
    # Arrange (preparar)
    local expected="valor esperado"

    # Act (ejecutar)
    run comando_a_testear arg1 arg2

    # Assert (verificar)
    assert_success
    assert_output_contains "$expected"
}
```

### Ejemplo Completo

```bash
#!/usr/bin/env bats

load test_helpers

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "install.sh creates symlinks in ~/.claude/skills/" {
    # Arrange
    local repo_dir
    repo_dir=$(create_fake_skills_repo)

    # Act
    cd "$repo_dir"
    run ./install.sh

    # Assert
    assert_success
    assert_directory_exists "$HOME/.claude/skills"
    assert_file_exists "$HOME/.claude/skills/python.md"
    assert_is_symlink "$HOME/.claude/skills/python.md"
}

@test "install.sh creates backup if previous installation exists" {
    # Arrange
    create_fake_installation
    local repo_dir
    repo_dir=$(create_fake_skills_repo)

    # Act
    cd "$repo_dir"
    run ./install.sh

    # Assert
    assert_success
    # Verificar que se creó backup (nombre contiene timestamp)
    local backup_count
    backup_count=$(find "$HOME/.claude/backups" -name "claude-skills-*" -type d | wc -l)
    [[ $backup_count -eq 1 ]]
}

@test "install.sh fails gracefully if git is not installed" {
    # Arrange
    mock_command git "exit 1"

    # Act
    run ./install.sh

    # Assert
    assert_failure
    assert_output_contains "git is required"
}
```

---

## 🧰 Funciones Helper Disponibles

### Setup y Teardown

| Función | Descripción |
|---------|-------------|
| `setup_test_env()` | Crea entorno de test aislado con $HOME temporal |
| `teardown_test_env()` | Limpia entorno de test |

### Assertions

| Función | Descripción |
|---------|-------------|
| `assert_success()` | Verifica exit code 0 |
| `assert_failure()` | Verifica exit code != 0 |
| `assert_file_exists(file)` | Verifica archivo existe |
| `assert_file_not_exists(file)` | Verifica archivo NO existe |
| `assert_directory_exists(dir)` | Verifica directorio existe |
| `assert_directory_not_exists(dir)` | Verifica directorio NO existe |
| `assert_is_symlink(path)` | Verifica es symlink |
| `assert_is_not_symlink(path)` | Verifica NO es symlink |
| `assert_output_contains(str)` | Verifica output contiene string |
| `assert_output_not_contains(str)` | Verifica output NO contiene string |
| `assert_output_equals(str)` | Verifica output es exactamente igual |
| `assert_file_contains(file, str)` | Verifica archivo contiene string |
| `assert_symlink_points_to(link, target)` | Verifica symlink apunta a target |

### Mocking

| Función | Descripción |
|---------|-------------|
| `mock_command(cmd, behavior)` | Mockea comando externo |
| `restore_command(cmd)` | Restaura comando mockeado |

**Ejemplo de mock:**

```bash
# Mockear git para que falle
mock_command git "exit 1"

# Mockear git para que retorne output específico
mock_command git 'echo "v1.2.3"'
```

### Fixtures

| Función | Descripción |
|---------|-------------|
| `create_fake_installation()` | Crea instalación falsa en $TEST_HOME/.claude |
| `create_fake_skills_repo(dir)` | Crea repositorio falso con skills |

### Utilidades

| Función | Descripción |
|---------|-------------|
| `count_files_in_dir(dir, pattern)` | Cuenta archivos en directorio |
| `count_symlinks_in_dir(dir)` | Cuenta symlinks en directorio |
| `capture_output(cmd)` | Captura stdout y stderr separados |
| `debug_test_env()` | Imprime estado del entorno (debugging) |

---

## 🔍 Debugging Tests

### Ver Output Detallado

```bash
./tests/run_tests.sh -v
```

### Debug de Entorno

Añade en tu test:

```bash
@test "mi test" {
    setup_test_env
    debug_test_env  # Imprime estado del entorno

    # ... rest of test
}
```

### Ejecutar bats Directamente

```bash
bats tests/test_install.sh
bats --tap tests/test_install.sh  # Formato TAP
```

---

## 📝 Convenciones

### Naming de Tests

```bash
# ✅ BIEN - Descriptivo y claro
@test "install.sh creates backup before overwriting"
@test "update.sh handles git conflicts gracefully"
@test "install.sh validates git is installed"

# ❌ MAL - Vago o poco claro
@test "test install"
@test "backup"
@test "it works"
```

### Estructura AAA (Arrange-Act-Assert)

Siempre usa comentarios para claridad:

```bash
@test "descripción" {
    # Arrange
    setup_inicial

    # Act
    run comando

    # Assert
    assert_success
}
```

### Un Assert por Concepto

```bash
# ✅ BIEN - Assertions relacionadas juntas
@test "install.sh creates all necessary files" {
    run ./install.sh

    assert_success
    assert_file_exists "$HOME/.claude/CLAUDE.md"
    assert_file_exists "$HOME/.claude/skills/python.md"
    assert_file_exists "$HOME/.claude/skills/bash-scripts.md"
}

# ✅ BIEN - Conceptos diferentes en tests separados
@test "install.sh creates symlinks" {
    run ./install.sh
    assert_is_symlink "$HOME/.claude/skills/python.md"
}

@test "install.sh creates backup" {
    create_fake_installation
    run ./install.sh
    assert_directory_exists "$HOME/.claude/backups/claude-skills-*"
}
```

---

## 🎯 Workflow TDD Completo

### 1. Crear Branch

```bash
git checkout develop
git checkout -b feature/t_03_tests_install_sh
```

### 2. RED - Test que Falla

```bash
vim tests/test_install.sh

@test "install.sh validates dependencies" {
    mock_command git "exit 1"
    run ./install.sh
    assert_failure
    assert_output_contains "git is required"
}

./tests/run_tests.sh
# ❌ FAIL
```

### 3. GREEN - Implementar Feature

```bash
vim install.sh

# Añadir validación:
if ! command -v git &> /dev/null; then
    echo "ERROR: git is required"
    exit 1
fi

./tests/run_tests.sh
# ✅ PASS
```

### 4. REFACTOR - Mejorar Código

```bash
vim install.sh

# Extraer a función
validate_dependencies() {
    if ! command -v git &> /dev/null; then
        log_error "git is required"
        return 1
    fi
}

./tests/run_tests.sh
# ✅ PASS (sigue pasando)
```

### 5. Commit

```bash
git add tests/test_install.sh install.sh
git commit -m "test: add dependency validation tests for install.sh

- Validates git is installed
- Validates ln command is available
- Tests fail gracefully with clear error messages

Part of #3"
```

---

## 🚀 CI/CD Integration

Los tests se ejecutan automáticamente en GitHub Actions:

```yaml
# .github/workflows/ci.yml

- name: Run tests
  run: ./tests/run_tests.sh
```

**Resultado**: PRs solo pueden mergearse si tests pasan (✅).

---

## 📚 Referencias

- **bats Documentation**: https://github.com/bats-core/bats-core
- **TDD con Bash**: https://github.com/sstephenson/bats
- **Workflow del Proyecto**: [docs/WORKFLOW.md](../docs/WORKFLOW.md)

---

## 🤝 Contributing

Al añadir tests:

1. ✅ Seguir convenciones de naming
2. ✅ Usar estructura AAA (Arrange-Act-Assert)
3. ✅ Añadir comentarios claros
4. ✅ Tests aislados (no dependen entre sí)
5. ✅ Limpiar en teardown (no dejar archivos temporales)

---

**Última actualización**: 2026-02-09
**Autor**: José Guillermo Moreu
