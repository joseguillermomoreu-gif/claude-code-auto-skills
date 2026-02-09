#!/usr/bin/env bash
#
# Script: test_helpers.sh
# Descripción: Funciones helper para tests de claude-code-auto-skills
# Autor: José Guillermo Moreu
# Fecha: 2026-02-09

# ============================================================================
# Setup y Teardown
# ============================================================================

# Crea entorno de test aislado
setup_test_env() {
    export TEST_HOME
    TEST_HOME="$(mktemp -d)"
    export HOME="$TEST_HOME"

    export TEST_CLAUDE_DIR="$TEST_HOME/.claude"
    export TEST_SKILLS_DIR="$TEST_CLAUDE_DIR/skills"

    # Crear estructura básica si es necesario
    mkdir -p "$TEST_CLAUDE_DIR"
    mkdir -p "$TEST_SKILLS_DIR"

    # Backup de variables de entorno originales
    export ORIGINAL_HOME="${ORIGINAL_HOME:-$HOME}"
}

# Limpia entorno de test
teardown_test_env() {
    if [[ -n "${TEST_HOME:-}" && -d "$TEST_HOME" ]]; then
        rm -rf "$TEST_HOME"
    fi

    # Restaurar HOME original si existe
    if [[ -n "${ORIGINAL_HOME:-}" ]]; then
        export HOME="$ORIGINAL_HOME"
    fi
}

# ============================================================================
# Assertions
# ============================================================================

# Verifica que el exit code sea 0 (success)
assert_success() {
    if [[ "$status" -ne 0 ]]; then
        echo "Expected success (exit code 0) but got: $status"
        echo "Output: $output"
        return 1
    fi
}

# Verifica que el exit code sea != 0 (failure)
assert_failure() {
    if [[ "$status" -eq 0 ]]; then
        echo "Expected failure (exit code != 0) but got success"
        echo "Output: $output"
        return 1
    fi
}

# Verifica que un archivo existe
assert_file_exists() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo "Expected file to exist: $file"
        return 1
    fi
}

# Verifica que un archivo NO existe
assert_file_not_exists() {
    local file="$1"

    if [[ -f "$file" ]]; then
        echo "Expected file to NOT exist: $file"
        return 1
    fi
}

# Verifica que un directorio existe
assert_directory_exists() {
    local dir="$1"

    if [[ ! -d "$dir" ]]; then
        echo "Expected directory to exist: $dir"
        return 1
    fi
}

# Verifica que un directorio NO existe
assert_directory_not_exists() {
    local dir="$1"

    if [[ -d "$dir" ]]; then
        echo "Expected directory to NOT exist: $dir"
        return 1
    fi
}

# Verifica que un path es un symlink
assert_is_symlink() {
    local path="$1"

    if [[ ! -L "$path" ]]; then
        echo "Expected symlink: $path"
        return 1
    fi
}

# Verifica que un path NO es un symlink
assert_is_not_symlink() {
    local path="$1"

    if [[ -L "$path" ]]; then
        echo "Expected NOT to be symlink: $path"
        return 1
    fi
}

# Verifica que el output contiene un string
assert_output_contains() {
    local expected="$1"

    if [[ ! "$output" =~ $expected ]]; then
        echo "Expected output to contain: $expected"
        echo "Actual output: $output"
        return 1
    fi
}

# Verifica que el output NO contiene un string
assert_output_not_contains() {
    local unexpected="$1"

    if [[ "$output" =~ $unexpected ]]; then
        echo "Expected output to NOT contain: $unexpected"
        echo "Actual output: $output"
        return 1
    fi
}

# Verifica que el output es exactamente igual
assert_output_equals() {
    local expected="$1"

    if [[ "$output" != "$expected" ]]; then
        echo "Expected output: $expected"
        echo "Actual output: $output"
        return 1
    fi
}

# Verifica que un archivo contiene un string
assert_file_contains() {
    local file="$1"
    local expected="$2"

    if [[ ! -f "$file" ]]; then
        echo "File does not exist: $file"
        return 1
    fi

    if ! grep -q "$expected" "$file"; then
        echo "Expected file '$file' to contain: $expected"
        echo "File contents:"
        cat "$file"
        return 1
    fi
}

# ============================================================================
# Mocking
# ============================================================================

# Mockea un comando externo
mock_command() {
    local command="$1"
    local mock_behavior="$2"

    # Crear directorio para mocks si no existe
    mkdir -p "$TEST_HOME/bin"

    # Crear mock script
    cat > "$TEST_HOME/bin/$command" << EOF
#!/usr/bin/env bash
$mock_behavior
EOF

    chmod +x "$TEST_HOME/bin/$command"

    # Añadir al PATH
    export PATH="$TEST_HOME/bin:$PATH"
}

# Restaura un comando mockeado
restore_command() {
    local command="$1"

    if [[ -f "$TEST_HOME/bin/$command" ]]; then
        rm "$TEST_HOME/bin/$command"
    fi
}

# ============================================================================
# Helpers de Fixtures
# ============================================================================

# Crea una instalación falsa para tests
create_fake_installation() {
    mkdir -p "$TEST_CLAUDE_DIR/skills"
    touch "$TEST_CLAUDE_DIR/CLAUDE.md"
    touch "$TEST_CLAUDE_DIR/skills/python.md"
    touch "$TEST_CLAUDE_DIR/skills/bash-scripts.md"

    # Crear config falsa
    cat > "$TEST_CLAUDE_DIR/.skills-config" << EOF
INSTALL_DATE="2026-01-01 12:00:00"
REPO_PATH="/fake/repo/path"
VERSION="1.0.0"
EOF
}

# Crea archivos de skill falsos en el repo
create_fake_skills_repo() {
    local repo_dir="${1:-$TEST_HOME/fake-repo}"

    mkdir -p "$repo_dir/skills"

    # Crear skills falsos
    echo "# Python Skill" > "$repo_dir/skills/python.md"
    echo "# Bash Scripts Skill" > "$repo_dir/skills/bash-scripts.md"
    echo "# TypeScript Skill" > "$repo_dir/skills/typescript.md"

    # Crear CLAUDE.md falso
    echo "# CLAUDE.md content" > "$repo_dir/CLAUDE.md"

    # Crear install.sh falso (básico)
    cat > "$repo_dir/install.sh" << 'EOF'
#!/usr/bin/env bash
echo "Fake install.sh"
mkdir -p "$HOME/.claude/skills"
ln -sf "$PWD/skills/"*.md "$HOME/.claude/skills/"
EOF

    chmod +x "$repo_dir/install.sh"

    export TEST_REPO_DIR="$repo_dir"
    echo "$repo_dir"
}

# ============================================================================
# Helpers de Validación
# ============================================================================

# Cuenta archivos en un directorio
count_files_in_dir() {
    local dir="$1"
    local pattern="${2:-*}"

    if [[ ! -d "$dir" ]]; then
        echo "0"
        return
    fi

    find "$dir" -maxdepth 1 -name "$pattern" -type f | wc -l
}

# Cuenta symlinks en un directorio
count_symlinks_in_dir() {
    local dir="$1"

    if [[ ! -d "$dir" ]]; then
        echo "0"
        return
    fi

    find "$dir" -maxdepth 1 -type l | wc -l
}

# Verifica que un symlink apunta a un target específico
assert_symlink_points_to() {
    local symlink="$1"
    local expected_target="$2"

    if [[ ! -L "$symlink" ]]; then
        echo "Not a symlink: $symlink"
        return 1
    fi

    local actual_target
    actual_target="$(readlink "$symlink")"

    if [[ "$actual_target" != "$expected_target" ]]; then
        echo "Expected symlink '$symlink' to point to: $expected_target"
        echo "Actually points to: $actual_target"
        return 1
    fi
}

# ============================================================================
# Helpers de Output
# ============================================================================

# Captura stdout y stderr de un comando
capture_output() {
    local temp_stdout
    local temp_stderr

    temp_stdout="$(mktemp)"
    temp_stderr="$(mktemp)"

    "$@" > "$temp_stdout" 2> "$temp_stderr"

    export captured_stdout
    export captured_stderr

    captured_stdout="$(cat "$temp_stdout")"
    captured_stderr="$(cat "$temp_stderr")"

    rm -f "$temp_stdout" "$temp_stderr"
}

# ============================================================================
# Debug Helpers
# ============================================================================

# Imprime el estado actual del entorno de test (para debugging)
debug_test_env() {
    echo "=== Test Environment Debug ==="
    echo "TEST_HOME: ${TEST_HOME:-not set}"
    echo "HOME: ${HOME:-not set}"
    echo "TEST_CLAUDE_DIR: ${TEST_CLAUDE_DIR:-not set}"
    echo ""
    echo "Files in TEST_HOME:"
    ls -la "${TEST_HOME:-/nonexistent}" 2>/dev/null || echo "TEST_HOME not found"
    echo ""
    echo "Files in TEST_CLAUDE_DIR:"
    ls -la "${TEST_CLAUDE_DIR:-/nonexistent}" 2>/dev/null || echo "TEST_CLAUDE_DIR not found"
    echo "=============================="
}

# ============================================================================
# Exports
# ============================================================================

# Exportar funciones para que estén disponibles en tests bats
export -f setup_test_env
export -f teardown_test_env
export -f assert_success
export -f assert_failure
export -f assert_file_exists
export -f assert_file_not_exists
export -f assert_directory_exists
export -f assert_directory_not_exists
export -f assert_is_symlink
export -f assert_is_not_symlink
export -f assert_output_contains
export -f assert_output_not_contains
export -f assert_output_equals
export -f assert_file_contains
export -f mock_command
export -f restore_command
export -f create_fake_installation
export -f create_fake_skills_repo
export -f count_files_in_dir
export -f count_symlinks_in_dir
export -f assert_symlink_points_to
export -f capture_output
export -f debug_test_env
