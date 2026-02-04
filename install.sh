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
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${MAGENTA}█████╗ ██╗   ██╗████████╗ ██████╗       ███████╗██╗  ██╗██╗██╗     ██╗     ███████╗${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${MAGENTA}██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗     ██╔════╝██║ ██╔╝██║██║     ██║     ██╔════╝${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${MAGENTA}███████║██║   ██║   ██║   ██║   ██║     ███████╗█████╔╝ ██║██║     ██║     ███████╗${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${MAGENTA}██╔══██║██║   ██║   ██║   ██║   ██║     ╚════██║██╔═██╗ ██║██║     ██║     ╚════██║${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${MAGENTA}██║  ██║╚██████╔╝   ██║   ╚██████╔╝     ███████║██║  ██╗██║███████╗███████╗███████║${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${MAGENTA}╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝      ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                   ${GREEN}🧠  Sistema Inteligente para Claude Code${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${YELLOW}📚 Carga automática de skills por proyecto${NC}                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${YELLOW}🔍 Auto-detección inteligente del stack tecnológico${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${YELLOW}⚡ 17 skills especializados listos para usar${NC}                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${BLUE}👨‍💻 Autor:${NC}   ${GREEN}José Guillermo Moreu${NC} ${YELLOW}(@joseguillermomoreu-gif)${NC}             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${BLUE}📦 Stack:${NC}  ${YELLOW}PHP/Symfony · Python · TypeScript · Playwright · OpenAI · Bash${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${BLUE}🔗 Repo:${NC}   ${YELLOW}github.com/joseguillermomoreu-gif/claude-code-auto-skills${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
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

        log_info "Backup creado: ${YELLOW}$backup_dir${NC}"
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
    log_info "CLAUDE.md → ${CYAN}~/.claude/CLAUDE.md${NC} (copiado)"

    # Symlink skills and templates (so they're editable in repo)
    ln -sf "$SCRIPT_DIR/skills" "$CLAUDE_DIR/skills"
    log_info "Skills → ${CYAN}~/.claude/skills${NC} (symlink)"

    ln -sf "$SCRIPT_DIR/templates" "$CLAUDE_DIR/templates"
    log_info "Templates → ${CYAN}~/.claude/templates${NC} (symlink)"
}

save_config() {
    log_step "Guardando configuración..."

    cat > "$CONFIG_FILE" << EOF
# Claude Code Auto-Skills Configuration
INSTALL_DATE="$(date +%Y-%m-%d)"
INSTALL_PATH="$SCRIPT_DIR"
VERSION="2.0.0"
MODE="direct-overwrite"
EOF

    log_info "Config guardada: ${YELLOW}$CONFIG_FILE${NC}"
}

verify_installation() {
    log_step "Verificando instalación..."

    local errors=0

    [ ! -f "$CLAUDE_DIR/CLAUDE.md" ] && log_error "CLAUDE.md missing" && ((errors++))
    [ ! -L "$CLAUDE_DIR/skills" ] && log_error "skills/ missing" && ((errors++))
    [ ! -f "$CONFIG_FILE" ] && log_error "config missing" && ((errors++))

    # Count skills
    local skill_count=0
    for skill in "$SCRIPT_DIR/skills"/*.md; do
        [ -f "$skill" ] && ((skill_count++))
    done

    if [ "$errors" -gt 0 ]; then
        log_error "Instalación incompleta"
        return 1
    fi

    log_info "Instalación OK - ${YELLOW}$skill_count${NC} skills disponibles"
}

print_success() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Instalación Completada${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${BLUE}📚 Skills instalados:${NC}"
    for skill in "$SCRIPT_DIR/skills"/*.md; do
        [ -f "$skill" ] && echo -e "   ${GREEN}✓${NC} $(basename "$skill")"
    done

    echo ""
    echo -e "${BLUE}📂 Configuración:${NC}"
    echo -e "   CLAUDE.md: ${CYAN}~/.claude/CLAUDE.md${NC} (archivo real)"
    echo -e "   Skills: ${CYAN}~/.claude/skills${NC} → ${YELLOW}$SCRIPT_DIR/skills${NC}"
    echo ""

    echo -e "${BLUE}💡 Uso:${NC}"
    echo -e "   ${CYAN}1.${NC} Abre Claude Code en cualquier proyecto:"
    echo -e "      ${YELLOW}cd ~/tu-proyecto && claude${NC}"
    echo ""
    echo -e "   ${CYAN}2.${NC} Claude detectará automáticamente tu stack"
    echo -e "      y cargará los skills relevantes"
    echo ""
    echo -e "   ${CYAN}3.${NC} Edita skills si quieres:"
    echo -e "      ${YELLOW}vim $SCRIPT_DIR/skills/php-symfony.md${NC}"
    echo ""

    echo -e "${GREEN}🚀 ¡Listo para usar!${NC}"
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
