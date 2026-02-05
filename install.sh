#!/usr/bin/env bash
#
# Claude Code Auto-Skills - Installation Script
# Sobrescribe ~/.claude/ con el sistema de skills auto-cargables
#

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CLAUDE_DIR="$HOME/.claude"
readonly CONFIG_FILE="$CLAUDE_DIR/.skills-config"

# Functions
log_info() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $*"; }
log_error() { echo -e "${RED}✗${NC} $*" >&2; }
log_step() { echo -e "\n${CYAN}→${NC} $*"; }

print_header() {
    clear
    echo ""
    echo -e "${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                                   ║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}     █████╗ ██╗   ██╗████████╗ ██████╗                  ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}    ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗                 ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}    ███████║██║   ██║   ██║   ██║   ██║                 ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}    ██╔══██║██║   ██║   ██║   ██║   ██║                 ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}    ██║  ██║╚██████╔╝   ██║   ╚██████╔╝                 ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝                  ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║                                                                   ║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}███████╗██╗  ██╗██╗██╗     ██╗     ███████╗            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}██╔════╝██║ ██╔╝██║██║     ██║     ██╔════╝            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}███████╗█████╔╝ ██║██║     ██║     ███████╗            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}╚════██║██╔═██╗ ██║██║     ██║     ╚════██║            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}███████║██║  ██╗██║███████╗███████╗███████║            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}    ${BOLD}${MAGENTA}╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝            ${NC}${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║                                                                   ║${NC}"
    echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}🧠  Sistema Inteligente de Skills para Claude Code${NC}"
    echo -e "  ${BLUE}📦  18 Skills Especializados | Auto-Detección | Context7${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}───────────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BOLD}${YELLOW}Autor:${NC}  José Guillermo Moreu ${CYAN}(@jgmoreu)${NC}"
    echo -e "  ${BOLD}${YELLOW}Repo:${NC}   ${CYAN}github.com/joseguillermomoreu-gif/claude-code-auto-skills${NC}"
    echo -e "${BOLD}${CYAN}───────────────────────────────────────────────────────────────────${NC}"
    echo ""
}

check_dependencies() {
    log_step "Verificando dependencias..."

    local missing_deps=()
    command -v git &>/dev/null || missing_deps+=("git")
    command -v ln &>/dev/null || missing_deps+=("coreutils")

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Falta: ${missing_deps[*]}"
        exit 1
    fi

    log_info "Dependencias OK"
}

backup_existing() {
    log_step "Verificando ~/.claude/ existente..."

    local backup_needed=false
    local backup_dir="$CLAUDE_DIR/.backup-$(date +%Y%m%d-%H%M%S)"

    # Check for existing content (not symlinks)
    if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
        backup_needed=true
    fi
    if [ -d "$CLAUDE_DIR/skills" ] && [ ! -L "$CLAUDE_DIR/skills" ]; then
        backup_needed=true
    fi

    if [ "$backup_needed" = true ]; then
        log_warning "Contenido existente detectado"
        mkdir -p "$backup_dir"

        [ -f "$CLAUDE_DIR/CLAUDE.md" ] && cp "$CLAUDE_DIR/CLAUDE.md" "$backup_dir/" 2>/dev/null || true
        [ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$backup_dir/" 2>/dev/null || true
        [ -d "$CLAUDE_DIR/templates" ] && cp -r "$CLAUDE_DIR/templates" "$backup_dir/" 2>/dev/null || true

        log_info "Backup creado: ${YELLOW}$(basename "$backup_dir")${NC}"
    else
        log_info "No hay contenido previo"
    fi
}

install_files() {
    log_step "Instalando archivos..."

    mkdir -p "$CLAUDE_DIR"

    # Remove existing files/symlinks
    rm -rf "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/templates" 2>/dev/null || true

    # Copy CLAUDE.md directly (not symlink)
    cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    log_info "CLAUDE.md → ${CYAN}~/.claude/CLAUDE.md${NC}"

    # Symlink skills and templates (so they're editable in repo)
    ln -sf "$SCRIPT_DIR/skills" "$CLAUDE_DIR/skills"
    log_info "Skills → ${CYAN}~/.claude/skills${NC} (symlink)"

    ln -sf "$SCRIPT_DIR/templates" "$CLAUDE_DIR/templates"
    log_info "Templates → ${CYAN}~/.claude/templates${NC} (symlink)"
}

save_config() {
    log_step "Guardando configuración..."

    {
        echo "# Claude Code Auto-Skills Configuration"
        echo "INSTALL_DATE=\"$(date +%Y-%m-%d)\""
        echo "INSTALL_PATH=\"$SCRIPT_DIR\""
        echo "VERSION=\"2.0.0\""
        echo "MODE=\"direct-overwrite\""
    } > "$CONFIG_FILE"

    log_info "Config guardada: ${YELLOW}$CONFIG_FILE${NC}"
}

verify_installation() {
    log_step "Verificando instalación..."

    local errors=0

    [ ! -f "$CLAUDE_DIR/CLAUDE.md" ] && log_error "CLAUDE.md missing" && ((errors++))
    [ ! -L "$CLAUDE_DIR/skills" ] && log_error "skills/ missing" && ((errors++))
    [ ! -f "$CONFIG_FILE" ] && log_error "config missing" && ((errors++))

    # Count skills using find (more reliable)
    local skill_count
    skill_count=$(find "$SCRIPT_DIR/skills" -maxdepth 1 -name "*.md" ! -name "README.md" -type f 2>/dev/null | wc -l)

    if [ "$errors" -gt 0 ]; then
        log_error "Instalación incompleta"
        return 1
    fi

    log_info "Instalación OK - ${BOLD}${YELLOW}${skill_count}${NC} skills disponibles"
}

print_success() {
    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}                  ✅ INSTALACIÓN COMPLETADA${NC}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${BOLD}${BLUE}📚 Skills instalados (18):${NC}"
    echo ""

    for skill in "$SCRIPT_DIR/skills"/*.md; do
        [ ! -f "$skill" ] && continue
        local skill_name
        skill_name=$(basename "$skill")
        [ "$skill_name" = "README.md" ] && continue
        echo -e "   ${GREEN}✓${NC} ${skill_name%.md}"
    done

    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}📂 Configuración:${NC}"
    echo -e "   ${GREEN}•${NC} CLAUDE.md: ${CYAN}~/.claude/CLAUDE.md${NC}"
    echo -e "   ${GREEN}•${NC} Skills: ${CYAN}~/.claude/skills${NC} → ${YELLOW}$SCRIPT_DIR/skills${NC}"
    echo ""
    echo -e "${BLUE}💡 Uso:${NC}"
    echo -e "   ${CYAN}1.${NC} Abre Claude Code: ${YELLOW}cd ~/tu-proyecto && claude${NC}"
    echo -e "   ${CYAN}2.${NC} Claude detectará tu stack automáticamente"
    echo -e "   ${CYAN}3.${NC} Actualizar: ${YELLOW}bash update.sh${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "   ${GREEN}✨ Gracias por usar Claude Code Auto-Skills ✨${NC}"
    echo ""
    echo -e "   ${YELLOW}Desarrollado con 💙 por José Guillermo Moreu${NC}"
    echo -e "   ${CYAN}github.com/joseguillermomoreu-gif/claude-code-auto-skills${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "   ${BOLD}${GREEN}🚀 ¡Listo para usar Claude Code!${NC}"
    echo ""
}

rollback() {
    log_error "Error en la instalación"
    [ -f "$CONFIG_FILE" ] && rm "$CONFIG_FILE"
    exit 1
}

# Main
main() {
    trap rollback ERR

    print_header
    check_dependencies
    backup_existing
    install_files
    save_config
    verify_installation
    print_success
}

main "$@"
