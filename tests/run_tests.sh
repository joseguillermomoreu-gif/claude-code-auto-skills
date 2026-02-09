#!/usr/bin/env bash
#
# Script: run_tests.sh
# Descripción: Ejecutor principal de tests para claude-code-auto-skills
# Autor: José Guillermo Moreu
# Fecha: 2026-02-09

set -euo pipefail

# Constantes
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colores
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Variables
VERBOSE=false
SPECIFIC_TEST=""

# Funciones
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_section() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
}

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [test_file]

Ejecuta tests para claude-code-auto-skills usando bats.

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    test_file       Run specific test file (e.g., test_install.sh)

Examples:
    $(basename "$0")                    # Run all tests
    $(basename "$0") test_install.sh    # Run specific test
    $(basename "$0") -v                 # Run all tests with verbose

EOF
}

check_bats_installed() {
    if ! command -v bats &> /dev/null; then
        log_error "bats not found. Please install it:"
        echo ""
        echo "  npm install -g bats"
        echo ""
        echo "Or on Ubuntu/Debian:"
        echo "  sudo apt-get install bats"
        echo ""
        return 1
    fi
}

find_test_files() {
    local test_pattern="${1:-test_*.sh}"

    if [[ -n "$SPECIFIC_TEST" ]]; then
        if [[ -f "$SCRIPT_DIR/$SPECIFIC_TEST" ]]; then
            echo "$SCRIPT_DIR/$SPECIFIC_TEST"
        else
            log_error "Test file not found: $SPECIFIC_TEST"
            return 1
        fi
    else
        find "$SCRIPT_DIR" -maxdepth 1 -name "$test_pattern" -type f | sort
    fi
}

run_tests() {
    local test_files
    test_files=$(find_test_files)

    if [[ -z "$test_files" ]]; then
        log_warning "No test files found matching pattern 'test_*.sh'"
        log_info "Tests will be created in issues #3 and #4"
        return 0
    fi

    local total_tests=0
    local failed_tests=0
    local passed_tests=0

    log_section "Running Tests"

    while IFS= read -r test_file; do
        local test_name
        test_name=$(basename "$test_file")

        log_info "Running: $test_name"

        if [[ "$VERBOSE" == "true" ]]; then
            if bats --tap "$test_file"; then
                ((passed_tests++))
            else
                ((failed_tests++))
            fi
        else
            if bats "$test_file"; then
                ((passed_tests++))
            else
                ((failed_tests++))
            fi
        fi

        ((total_tests++))
        echo ""
    done <<< "$test_files"

    # Summary
    log_section "Test Summary"

    echo "Total: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"

    if [[ $failed_tests -gt 0 ]]; then
        echo -e "${RED}Failed: $failed_tests${NC}"
        log_error "Some tests failed!"
        return 1
    else
        log_info "All tests passed! ✓"
        return 0
    fi
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            test_*.sh)
                SPECIFIC_TEST="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    cd "$PROJECT_ROOT"

    log_section "Claude Code Auto-Skills - Test Runner"

    # Verificar bats está instalado
    if ! check_bats_installed; then
        exit 1
    fi

    log_info "Project root: $PROJECT_ROOT"
    log_info "Test directory: $SCRIPT_DIR"
    [[ "$VERBOSE" == "true" ]] && log_info "Verbose mode: ON"
    echo ""

    # Ejecutar tests
    if run_tests; then
        exit 0
    else
        exit 1
    fi
}

# Ejecutar solo si script es ejecutado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
