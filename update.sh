#!/usr/bin/env bash
#
# Claude Code Auto-Skills - Update Script
# Actualiza desde git y recopia CLAUDE.md
#

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Config
readonly CLAUDE_DIR="$HOME/.claude"
readonly CONFIG_FILE="$CLAUDE_DIR/.skills-config"

log_info() { echo -e "${GREEN}✓${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*" >&2; }
log_step() { echo -e "\n${CYAN}→${NC} $*"; }

check_installation() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "No hay instalación"
        log_error "Ejecuta: ./install.sh"
        exit 1
    fi

    source "$CONFIG_FILE"

    if [ ! -d "$INSTALL_PATH" ]; then
        log_error "Repo no encontrado en: $INSTALL_PATH"
        exit 1
    fi
}

update_repo() {
    log_step "Actualizando repositorio..."

    cd "$INSTALL_PATH"

    if [ ! -d ".git" ]; then
        log_error "No es un repo git"
        exit 1
    fi

    # Check local changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_error "Tienes cambios sin commitear"
        echo ""
        echo "Opciones:"
        echo "1. Commitear y actualizar"
        echo "2. Stash y actualizar"
        echo "3. Cancelar"
        echo ""
        read -p "¿Qué hacer? (1/2/3): " choice

        case $choice in
            1)
                echo ""
                read -p "Mensaje del commit: " msg
                git add .
                git commit -m "$msg"
                ;;
            2)
                git stash
                log_info "Cambios en stash"
                ;;
            3)
                log_info "Cancelado"
                exit 0
                ;;
            *)
                log_error "Opción inválida"
                exit 1
                ;;
        esac
    fi

    # Pull
    local branch
    branch=$(git branch --show-current)

    log_info "Actualizando branch: ${YELLOW}$branch${NC}"

    if git pull origin "$branch"; then
        log_info "Repo actualizado"
    else
        log_error "Error al actualizar"
        exit 1
    fi
}

update_claude_md() {
    log_step "Actualizando CLAUDE.md..."

    # Copy updated CLAUDE.md
    cp "$INSTALL_PATH/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    log_info "CLAUDE.md actualizado en ~/.claude/"
}

show_changes() {
    log_step "Cambios aplicados..."

    cd "$INSTALL_PATH"

    echo ""
    echo -e "${CYAN}Último commit:${NC}"
    git log -1 --pretty=format:"%h - %s (%ar)" --color=always
    echo ""
    echo ""

    echo -e "${CYAN}Archivos modificados:${NC}"
    git diff --name-status HEAD@{1} HEAD 2>/dev/null | while read -r status file; do
        case $status in
            M) echo -e "   ${YELLOW}M${NC} $file" ;;
            A) echo -e "   ${GREEN}A${NC} $file" ;;
            D) echo -e "   ${RED}D${NC} $file" ;;
        esac
    done || log_info "Sin cambios"

    echo ""
}

print_success() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Actualización Completada${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    log_info "Cambios disponibles inmediatamente"
    echo ""
}

main() {
    echo ""
    echo -e "${CYAN}🔄 Claude Code Auto-Skills - Actualización${NC}"
    echo ""

    check_installation
    update_repo
    update_claude_md
    show_changes
    print_success
}

main "$@"
