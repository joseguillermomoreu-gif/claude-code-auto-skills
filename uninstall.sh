#!/usr/bin/env bash
#
# Claude Code Auto-Skills - Uninstall Script
# Elimina el sistema y opcionalmente restaura backup
#

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Config
readonly CLAUDE_DIR="$HOME/.claude"
readonly CONFIG_FILE="$CLAUDE_DIR/.skills-config"

log_info() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $*"; }
log_error() { echo -e "${RED}✗${NC} $*" >&2; }
log_step() { echo -e "\n${CYAN}→${NC} $*"; }

check_installation() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "No hay instalación de Claude Code Auto-Skills"
        exit 1
    fi

    source "$CONFIG_FILE"
}

confirm_uninstall() {
    echo ""
    log_warning "Desinstalación de Claude Code Auto-Skills"
    echo ""
    echo -e "   Se eliminará:"
    echo -e "   • ${CYAN}~/.claude/CLAUDE.md${NC}"
    echo -e "   • ${CYAN}~/.claude/skills${NC} (symlink)"
    echo -e "   • ${CYAN}~/.claude/templates${NC} (symlink)"
    echo -e "   • ${CYAN}~/.claude/.skills-config${NC}"
    echo ""
    read -p "¿Continuar? (s/n): " confirm

    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
        log_info "Desinstalación cancelada"
        exit 0
    fi
}

remove_files() {
    log_step "Eliminando archivos..."

    local removed=0

    if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        rm "$CLAUDE_DIR/CLAUDE.md"
        log_info "Eliminado: CLAUDE.md"
        ((removed++))
    fi

    if [ -L "$CLAUDE_DIR/skills" ]; then
        rm "$CLAUDE_DIR/skills"
        log_info "Eliminado: skills/ (symlink)"
        ((removed++))
    fi

    if [ -L "$CLAUDE_DIR/templates" ]; then
        rm "$CLAUDE_DIR/templates"
        log_info "Eliminado: templates/ (symlink)"
        ((removed++))
    fi

    if [ -f "$CONFIG_FILE" ]; then
        rm "$CONFIG_FILE"
        log_info "Eliminado: config"
        ((removed++))
    fi

    log_info "Total eliminado: ${YELLOW}$removed${NC} archivos"
}

restore_backup() {
    log_step "Verificando backups..."

    # Find latest backup
    local latest_backup
    latest_backup=$(find "$CLAUDE_DIR" -maxdepth 1 -type d -name ".backup-*" 2>/dev/null | sort -r | head -n 1)

    if [ -z "$latest_backup" ]; then
        log_info "No hay backups disponibles"
        return 0
    fi

    echo ""
    echo -e "   Backup encontrado: ${YELLOW}$(basename "$latest_backup")${NC}"
    echo ""

    # List backup contents
    echo -e "   Contenido del backup:"
    ls -la "$latest_backup" 2>/dev/null | tail -n +4 | awk '{print "   • " $9}' || true
    echo ""

    read -p "¿Restaurar este backup? (s/n): " restore

    if [[ "$restore" =~ ^[sS]$ ]]; then
        local restored=0

        if [ -f "$latest_backup/CLAUDE.md" ]; then
            cp "$latest_backup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
            log_info "Restaurado: CLAUDE.md"
            ((restored++))
        fi

        if [ -d "$latest_backup/skills" ]; then
            cp -r "$latest_backup/skills" "$CLAUDE_DIR/skills"
            log_info "Restaurado: skills/"
            ((restored++))
        fi

        if [ -d "$latest_backup/templates" ]; then
            cp -r "$latest_backup/templates" "$CLAUDE_DIR/templates"
            log_info "Restaurado: templates/"
            ((restored++))
        fi

        if [ "$restored" -gt 0 ]; then
            log_info "Backup restaurado exitosamente"
            echo ""
            echo -e "${YELLOW}💡 Nota:${NC} El backup se conserva en: ${CYAN}$latest_backup${NC}"
        else
            log_warning "Backup vacío, nada que restaurar"
        fi
    else
        log_info "Backup conservado en: ${YELLOW}$latest_backup${NC}"
    fi
}

print_success() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Desinstalación Completada${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    log_info "~/.claude/ limpio"
    echo ""
}

print_header() {
    clear
    echo ""
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                                   ║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}     █████╗ ██╗   ██╗████████╗ ██████╗                  ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗                 ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}    ███████║██║   ██║   ██║   ██║   ██║                 ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}    ██╔══██║██║   ██║   ██║   ██║   ██║                 ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝                 ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝                  ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║                                                                   ║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}███████╗██╗  ██╗██╗██╗     ██╗     ███████╗            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}██╔════╝██║ ██╔╝██║██║     ██║     ██╔════╝            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}███████╗█████╔╝ ██║██║     ██║     ███████╗            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}╚════██║██╔═██╗ ██║██║     ██║     ╚════██║            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}███████║██║  ██╗██║███████╗███████╗███████║            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${RED}╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║                                                                   ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${YELLOW}🗑️  Desinstalación del Sistema de Skills${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}───────────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BOLD}${YELLOW}Autor:${NC}  José Guillermo Moreu ${CYAN}(@jgmoreu)${NC}"
    echo -e "  ${BOLD}${YELLOW}Repo:${NC}   ${CYAN}github.com/joseguillermomoreu-gif/claude-code-auto-skills${NC}"
    echo -e "${BOLD}${CYAN}───────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

main() {
    print_header
    check_installation
    confirm_uninstall
    remove_files
    restore_backup
    print_success
}

main "$@"
