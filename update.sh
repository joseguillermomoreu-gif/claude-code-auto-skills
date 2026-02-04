#!/usr/bin/env bash
#
# Claude Code Auto-Skills - Update Script
# Actualiza los skills desde el repositorio
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

log_info() {
    echo -e "${GREEN}✓${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

log_step() {
    echo -e "\n${CYAN}→${NC} $*"
}

check_installation() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "No se encontró instalación de Claude Code Auto-Skills"
        log_error "Ejecuta primero: ./install.sh"
        exit 1
    fi

    source "$CONFIG_FILE"

    if [ ! -d "$SKILLS_REPO_PATH" ]; then
        log_error "Repositorio no encontrado en: $SKILLS_REPO_PATH"
        log_error "La instalación puede estar corrupta"
        exit 1
    fi
}

update_repo() {
    log_step "Actualizando repositorio..."

    cd "$SKILLS_REPO_PATH"

    # Check if it's a git repo
    if [ ! -d ".git" ]; then
        log_error "El directorio no es un repositorio git"
        log_error "No se puede actualizar automáticamente"
        exit 1
    fi

    # Check for local changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_error "Tienes cambios locales sin commitear"
        echo ""
        echo "Opciones:"
        echo "1. Commitear cambios y actualizar"
        echo "2. Hacer stash y actualizar"
        echo "3. Cancelar"
        echo ""
        read -p "¿Qué prefieres? (1/2/3): " choice

        case $choice in
            1)
                echo ""
                read -p "Mensaje del commit: " commit_msg
                git add .
                git commit -m "$commit_msg"
                ;;
            2)
                git stash
                log_info "Cambios guardados en stash"
                ;;
            3)
                log_info "Actualización cancelada"
                exit 0
                ;;
            *)
                log_error "Opción inválida"
                exit 1
                ;;
        esac
    fi

    # Update from remote
    local current_branch
    current_branch=$(git branch --show-current)

    log_info "Actualizando branch: ${YELLOW}$current_branch${NC}"

    if git pull origin "$current_branch"; then
        log_info "Repositorio actualizado exitosamente"

        # Si modo COPY, copiar CLAUDE.md actualizado
        if [ "${INSTALL_MODE:-}" = "copy" ]; then
            log_step "Actualizando CLAUDE.md (modo COPY)..."
            cp "$SKILLS_REPO_PATH/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
            log_info "CLAUDE.md actualizado en ~/.claude/"
        fi
    else
        log_error "Error al actualizar el repositorio"
        exit 1
    fi
}

verify_installation() {
    log_step "Verificando instalación..."

    local errors=0

    # Verificar según modo de instalación
    if [ "${INSTALL_MODE:-symlink}" = "copy" ]; then
        # Modo COPY: CLAUDE.md es archivo, resto symlinks
        if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ]; then
            log_error "CLAUDE.md no encontrado"
            ((errors++))
        fi
        if [ ! -L "$CLAUDE_DIR/skills" ]; then
            log_error "skills/ symlink no encontrado"
            ((errors++))
        fi
        log_info "Instalación OK (modo COPY)"
    else
        # Modo SYMLINK: todo symlinks
        if [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
            log_error "CLAUDE.md symlink no encontrado"
            ((errors++))
        fi
        if [ ! -L "$CLAUDE_DIR/skills" ]; then
            log_error "skills/ symlink no encontrado"
            ((errors++))
        fi
        log_info "Instalación OK (modo SYMLINK)"
    fi

    if [ "$errors" -gt 0 ]; then
        log_error "Archivos rotos, considera reinstalar: ./install.sh"
        exit 1
    fi
}

show_changes() {
    log_step "Cambios aplicados..."

    cd "$SKILLS_REPO_PATH"

    # Show last commit
    echo ""
    echo -e "${CYAN}Último commit:${NC}"
    git log -1 --pretty=format:"%h - %s (%ar)" --color=always
    echo ""
    echo ""

    # Show changed files in last pull
    echo -e "${CYAN}Archivos actualizados:${NC}"
    git diff --name-status HEAD@{1} HEAD 2>/dev/null | while read -r status file; do
        case $status in
            M) echo -e "   ${YELLOW}M${NC} $file (modificado)" ;;
            A) echo -e "   ${GREEN}A${NC} $file (añadido)" ;;
            D) echo -e "   ${RED}D${NC} $file (eliminado)" ;;
        esac
    done || log_info "No hay cambios nuevos"

    echo ""
}

print_success() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Actualización completada${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    log_info "Los cambios están disponibles inmediatamente en Claude Code"
    echo ""
}

main() {
    echo ""
    echo -e "${CYAN}🔄 Claude Code Auto-Skills - Actualización${NC}"
    echo ""

    check_installation
    verify_installation
    update_repo
    show_changes
    print_success
}

main "$@"
