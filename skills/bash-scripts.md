# Bash Scripts - Buenas Prácticas

> **Shell**: Bash 4.x+
> **Última actualización**: 2026-02-04

## Template Estándar

```bash
#!/usr/bin/env bash
#
# Script: nombre_descriptivo.sh
# Descripción: Qué hace este script
# Autor: Tu nombre
# Fecha: 2026-02-04

set -euo pipefail  # Strict mode
IFS=$'\n\t'        # Internal Field Separator seguro

# Constantes
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Colores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

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

usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <argument>

Description:
    Descripción detallada del script

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -d, --debug     Enable debug mode

Examples:
    ${SCRIPT_NAME} --verbose arg1
    ${SCRIPT_NAME} -d arg1 arg2

EOF
}

main() {
    # Validación de argumentos
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi

    # Lógica principal aquí
    log_info "Starting script..."

    # Tu código aquí

    log_info "Script completed successfully"
}

# Ejecutar main solo si el script es ejecutado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Strict Mode Explicado

```bash
# set -e: Exit inmediato si un comando falla
set -e

# set -u: Error si se usa variable no declarada
set -u

# set -o pipefail: Si un comando en un pipe falla, el pipe falla
set -o pipefail

# Combinado (recomendado):
set -euo pipefail
```

## Naming Conventions

```bash
# Variables locales: snake_case
local user_name="john"
local file_path="/tmp/data.txt"

# Constantes/Globales: UPPER_SNAKE_CASE
readonly MAX_RETRIES=3
readonly API_BASE_URL="https://api.example.com"

# Funciones: snake_case
function process_data() {
    # ...
}

# Archivos: kebab-case o snake_case
deploy-prod.sh
backup_database.sh
```

## Validación de Argumentos

```bash
#!/usr/bin/env bash
set -euo pipefail

# Parsing de argumentos con getopts
while getopts ":hvd:f:" opt; do
    case ${opt} in
        h )
            usage
            exit 0
            ;;
        v )
            VERBOSE=true
            ;;
        d )
            DIRECTORY="$OPTARG"
            ;;
        f )
            FILE="$OPTARG"
            ;;
        \? )
            log_error "Invalid option: -$OPTARG"
            usage
            exit 1
            ;;
        : )
            log_error "Option -$OPTARG requires an argument"
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Validar argumentos requeridos
if [[ -z "${DIRECTORY:-}" ]]; then
    log_error "Directory is required"
    usage
    exit 1
fi
```

## Manejo de Errores

```bash
# Trap para cleanup en exit
cleanup() {
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed with exit code: $exit_code"
    fi

    # Cleanup temporal files
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi

    exit "$exit_code"
}

trap cleanup EXIT INT TERM

# Función para comando que puede fallar
run_command() {
    local cmd="$1"

    if ! eval "$cmd"; then
        log_error "Command failed: $cmd"
        return 1
    fi
}

# Retry con backoff
retry_with_backoff() {
    local max_attempts=3
    local delay=1
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        fi

        log_warning "Attempt $attempt failed, retrying in ${delay}s..."
        sleep "$delay"
        delay=$((delay * 2))
        attempt=$((attempt + 1))
    done

    log_error "Command failed after $max_attempts attempts"
    return 1
}
```

## Working con Files y Directorios

```bash
# Verificar si existe archivo
if [[ -f "$file_path" ]]; then
    log_info "File exists: $file_path"
fi

# Verificar si existe directorio
if [[ -d "$dir_path" ]]; then
    log_info "Directory exists: $dir_path"
fi

# Crear directorio si no existe
mkdir -p "$output_dir"

# Leer archivo línea por línea
while IFS= read -r line; do
    echo "Processing: $line"
done < "$input_file"

# Iterar sobre archivos
for file in "$directory"/*.txt; do
    if [[ -f "$file" ]]; then
        process_file "$file"
    fi
done

# Archivo temporal seguro
TEMP_FILE="$(mktemp)"
trap 'rm -f "$TEMP_FILE"' EXIT
```

## Variables y Strings

```bash
# Siempre entrecomillar variables
echo "$variable"           # ✅ BIEN
echo $variable            # ❌ MAL (word splitting)

# Default values
name="${USER_NAME:-default_name}"

# Verificar si variable está vacía
if [[ -z "${VAR:-}" ]]; then
    log_error "VAR is empty"
fi

# String manipulation
filename="document.pdf"
echo "${filename%.pdf}"      # document (remove suffix)
echo "${filename#document.}" # pdf (remove prefix)

path="/usr/local/bin/script.sh"
echo "${path##*/}"  # script.sh (basename)
echo "${path%/*}"   # /usr/local/bin (dirname)
```

## Condicionales

```bash
# Usar [[ ]] en lugar de [ ]
if [[ "$var" == "value" ]]; then
    # ...
fi

# Verificaciones comunes
if [[ -f "$file" ]]; then          # File exists
if [[ -d "$dir" ]]; then           # Directory exists
if [[ -x "$script" ]]; then        # Is executable
if [[ -n "$var" ]]; then           # String not empty
if [[ -z "$var" ]]; then           # String is empty
if [[ "$a" -eq "$b" ]]; then       # Numbers equal
if [[ "$a" -lt "$b" ]]; then       # a less than b

# Pattern matching
if [[ "$filename" == *.txt ]]; then
    echo "Text file"
fi

# Negación
if [[ ! -f "$file" ]]; then
    echo "File does not exist"
fi
```

## Arrays

```bash
# Declarar array
files=("file1.txt" "file2.txt" "file3.txt")

# Añadir elemento
files+=("file4.txt")

# Iterar
for file in "${files[@]}"; do
    echo "$file"
done

# Longitud
echo "${#files[@]}"  # 4

# Acceder por índice
echo "${files[0]}"   # file1.txt

# Todos los elementos
echo "${files[@]}"   # file1.txt file2.txt file3.txt file4.txt
```

## Funciones

```bash
# Función básica
function hello() {
    local name="$1"
    echo "Hello, $name!"
}

# Función con múltiples argumentos
function deploy() {
    local environment="$1"
    local version="$2"

    log_info "Deploying version $version to $environment"

    # Return value (0 = success, >0 = error)
    return 0
}

# Función que retorna string
function get_timestamp() {
    echo "$(date +%Y-%m-%d_%H-%M-%S)"
}

# Uso:
timestamp=$(get_timestamp)
echo "Timestamp: $timestamp"

# Función con validación
function require_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        return 1
    fi
}
```

## Logging con Timestamps

```bash
# Logger mejorado
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
        INFO)
            echo -e "${timestamp} ${GREEN}[INFO]${NC} ${message}"
            ;;
        ERROR)
            echo -e "${timestamp} ${RED}[ERROR]${NC} ${message}" >&2
            ;;
        WARNING)
            echo -e "${timestamp} ${YELLOW}[WARNING]${NC} ${message}"
            ;;
        DEBUG)
            if [[ "${DEBUG:-false}" == "true" ]]; then
                echo -e "${timestamp} [DEBUG] ${message}"
            fi
            ;;
    esac
}

# Log a archivo también
log_to_file() {
    local level="$1"
    shift
    local message="$*"

    log "$level" "$message"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
}
```

## Ejemplo Completo: Deploy Script

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat << EOF
Usage: $(basename "$0") <environment>

Deploy application to specified environment.

Arguments:
    environment    Target environment (staging|production)

Examples:
    $(basename "$0") staging
    $(basename "$0") production
EOF
}

validate_environment() {
    local env="$1"

    if [[ ! "$env" =~ ^(staging|production)$ ]]; then
        log_error "Invalid environment: $env"
        usage
        exit 1
    fi
}

run_tests() {
    log_info "Running tests..."

    if ! npm test; then
        log_error "Tests failed"
        return 1
    fi

    log_info "Tests passed ✓"
}

build_application() {
    log_info "Building application..."

    if ! npm run build; then
        log_error "Build failed"
        return 1
    fi

    log_info "Build completed ✓"
}

deploy() {
    local environment="$1"

    log_info "Deploying to $environment..."

    # Deployment logic here
    # Example: rsync, scp, aws s3 sync, etc.

    log_info "Deployment completed ✓"
}

main() {
    if [[ $# -ne 1 ]]; then
        usage
        exit 1
    fi

    local environment="$1"

    validate_environment "$environment"

    log_info "Starting deployment to $environment"

    run_tests
    build_application
    deploy "$environment"

    log_info "✓ Deployment to $environment successful!"
}

main "$@"
```

## Comandos Útiles

```bash
# Verificar sintaxis sin ejecutar
bash -n script.sh

# Debug mode (muestra cada comando)
bash -x script.sh

# ShellCheck (linter)
shellcheck script.sh
```

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- Detectes mejores patrones de error handling
- Encuentres utilities útiles que uso frecuentemente
- Veas anti-patterns en mis scripts

**Preserva siempre**:
- Strict mode (set -euo pipefail)
- Convenciones de naming
- Template estándar con logging

**Usa Context7** si es necesario para:
```bash
# Herramientas específicas
resolve-library-id: "bash" o herramienta específica
query-docs: "bash best practices 2026"
```
