#!/usr/bin/env bash
#
# Claude Code Auto-Skills - Uninstall Script
# Desinstala el sistema de skills y limpia symlinks
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

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $*"
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
        log_error "Nada que desinstalar"
        exit 1
    fi

    source "$CONFIG_FILE"
}

confirm_uninstall() {
    echo ""
    log_warning "Estás a punto de desinstalar Claude Code Auto-Skills"
    echo ""
    echo -e "   Instalación actual: ${YELLOW}$SKILLS_REPO_PATH${NC}"
    echo ""
    read -p "¿Continuar con la desinstalación? (s/n): " confirm

    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
        log_info "Desinstalación cancelada"
        exit 0
    fi
}

remove_symlinks() {
    log_step "Eliminando symlinks..."

    local removed=0

    if [ -L "$CLAUDE_DIR/CLAUDE.md" ]; then
        rm "$CLAUDE_DIR/CLAUDE.md"
        log_info "Eliminado: ~/.claude/CLAUDE.md"
        ((removed++))
    fi

    if [ -L "$CLAUDE_DIR/skills" ]; then
        rm "$CLAUDE_DIR/skills"
        log_info "Eliminado: ~/.claude/skills"
        ((removed++))
    fi

    if [ -L "$CLAUDE_DIR/templates" ]; then
        rm "$CLAUDE_DIR/templates"
        log_info "Eliminado: ~/.claude/templates"
        ((removed++))
    fi

    if [ "$removed" -eq 0 ]; then
        log_warning "No se encontraron symlinks para eliminar"
    else
        log_info "Total eliminados: ${YELLOW}$removed${NC} symlinks"
    fi
}

restore_backup() {
    log_step "Verificando backups..."

    # Find latest backup
    local latest_backup
    latest_backup=$(find "$CLAUDE_DIR" -maxdepth 1 -type d -name ".backup-*" 2>/dev/null | sort -r | head -n 1)

    if [ -z "$latest_backup" ]; then
        log_info "No hay backups para restaurar"
        return 0
    fi

    echo ""
    echo -e "   Backup encontrado: ${YELLOW}$(basename "$latest_backup")${NC}"
    echo ""
    read -p "¿Restaurar configuración original desde este backup? (s/n): " restore

    if [[ "$restore" =~ ^[sS]$ ]]; then
        if [ -f "$latest_backup/CLAUDE.md" ]; then
            cp "$latest_backup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
            log_info "Restaurado: CLAUDE.md"
        fi

        if [ -d "$latest_backup/skills" ]; then
            cp -r "$latest_backup/skills" "$CLAUDE_DIR/skills"
            log_info "Restaurado: skills/"
        fi

        if [ -d "$latest_backup/templates" ]; then
            cp -r "$latest_backup/templates" "$CLAUDE_DIR/templates"
            log_info "Restaurado: templates/"
        fi

        log_info "Backup restaurado exitosamente"
    else
        log_info "Backup conservado en: ${YELLOW}$latest_backup${NC}"
    fi
}

remove_config() {
    log_step "Eliminando configuración..."

    if [ -f "$CONFIG_FILE" ]; then
        rm "$CONFIG_FILE"
        log_info "Configuración eliminada"
    fi
}

remove_repository() {
    echo ""
    echo -e "${YELLOW}⚠${NC}  Repositorio: ${YELLOW}$SKILLS_REPO_PATH${NC}"
    echo ""
    echo "   Opciones:"
    echo "   1. Conservar (podrás reinstalar después)"
    echo "   2. Eliminar completamente"
    echo ""
    read -p "   ¿Qué prefieres? (1/2): " choice

    case $choice in
        1)
            log_info "Repositorio conservado en: ${YELLOW}$SKILLS_REPO_PATH${NC}"
            log_info "Para reinstalar: cd $SKILLS_REPO_PATH && ./install.sh"
            ;;
        2)
            if [ -d "$SKILLS_REPO_PATH" ]; then
                echo ""
                log_warning "¡CUIDADO! Esto eliminará permanentemente:"
                echo -e "   ${RED}$SKILLS_REPO_PATH${NC}"
                echo ""
                read -p "¿Estás SEGURO? Escribe 'DELETE' para confirmar: " confirm_delete

                if [ "$confirm_delete" = "DELETE" ]; then
                    rm -rf "$SKILLS_REPO_PATH"
                    log_info "Repositorio eliminado"
                else
                    log_info "Eliminación cancelada, repositorio conservado"
                fi
            else
                log_warning "Repositorio no encontrado, puede estar ya eliminado"
            fi
            ;;
        *)
            log_info "Opción inválida, conservando repositorio"
            ;;
    esac
}

print_success() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Desinstalación completada${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ -d "$SKILLS_REPO_PATH" ]; then
        log_info "Repositorio conservado, puedes reinstalar cuando quieras"
        echo -e "   ${YELLOW}cd $SKILLS_REPO_PATH && ./install.sh${NC}"
    fi

    echo ""
    log_info "~/.claude/ ha vuelto a su estado original"
    echo ""
}

main() {
    echo ""
    echo -e "${CYAN}🗑️  Claude Code Auto-Skills - Desinstalación${NC}"

    check_installation
    confirm_uninstall
    remove_symlinks
    restore_backup
    remove_config
    remove_repository
    print_success
}

main "$@"
