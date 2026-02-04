#!/usr/bin/env bash
#
# Claude Code Auto-Skills - Update Script
# Actualiza automáticamente desde el repositorio Git
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
readonly CLAUDE_DIR="$HOME/.claude"
readonly CONFIG_FILE="$CLAUDE_DIR/.skills-config"
readonly BACKUP_DIR="$CLAUDE_DIR/.backup-update-$(date +%Y%m%d-%H%M%S)"

# Functions
log_info() { echo -e "${GREEN}✓${NC} $*"; }
log_warning() { echo -e "${YELLOW}⚠${NC}  $*"; }
log_error() { echo -e "${RED}✗${NC} $*" >&2; }
log_step() { echo -e "\n${CYAN}→${NC} $*"; }

print_header() {
    clear
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${MAGENTA}                    AUTO-SKILLS UPDATER${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e ""
    echo -e "  ${GREEN}🔄  Sistema de Actualización Automática${NC}"
    echo -e "  ${BLUE}📦  Claude Code Auto-Skills${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

check_installation() {
    log_step "Verificando instalación existente..."

    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "No se encontró instalación previa"
        echo ""
        echo -e "   ${YELLOW}Ejecuta primero:${NC} ${CYAN}bash install.sh${NC}"
        echo ""
        exit 1
    fi

    log_info "Instalación encontrada"
}

get_current_version() {
    local version="unknown"
    if [ -f "$CONFIG_FILE" ]; then
        version=$(grep '^VERSION=' "$CONFIG_FILE" 2>/dev/null | cut -d'"' -f2 || echo "unknown")
    fi
    echo "$version"
}

get_install_path() {
    if [ -f "$CONFIG_FILE" ]; then
        grep '^INSTALL_PATH=' "$CONFIG_FILE" 2>/dev/null | cut -d'"' -f2 || echo ""
    else
        echo ""
    fi
}

backup_current() {
    log_step "Creando backup de seguridad..."

    mkdir -p "$BACKUP_DIR"

    # Backup CLAUDE.md
    if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
        cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/"
    fi

    # Backup config
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$BACKUP_DIR/"
    fi

    log_info "Backup creado: ${YELLOW}$(basename "$BACKUP_DIR")${NC}"
}

update_repository() {
    log_step "Actualizando desde repositorio..."

    local install_path
    install_path=$(get_install_path)

    if [ -z "$install_path" ] || [ ! -d "$install_path" ]; then
        log_error "No se encontró el path de instalación: '$install_path'"
        exit 1
    fi

    cd "$install_path" || exit 1

    # Check if it's a git repo
    if [ ! -d ".git" ]; then
        log_error "El directorio de instalación no es un repositorio Git"
        exit 1
    fi

    # Stash any local changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_warning "Guardando cambios locales..."
        git stash push -m "auto-skills-update-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
    fi

    # Pull latest
    log_info "Descargando última versión..."
    if git pull origin master 2>&1; then
        log_info "Repositorio actualizado"
    else
        log_error "Error al hacer git pull"
        exit 1
    fi
}

get_new_version() {
    local install_path
    install_path=$(get_install_path)

    if [ -f "$install_path/install.sh" ]; then
        # Look for VERSION= line (with or without readonly)
        grep 'VERSION=' "$install_path/install.sh" 2>/dev/null | head -1 | cut -d'"' -f2 || echo "unknown"
    else
        echo "unknown"
    fi
}

count_skills() {
    local install_path
    install_path=$(get_install_path)

    local count=0
    if [ -d "$install_path/skills" ]; then
        for skill in "$install_path/skills"/*.md; do
            # Skip if file doesn't exist or is README.md
            if [ -f "$skill" ] && [[ "$(basename "$skill")" != "README.md" ]]; then
                ((count++))
            fi
        done
    fi
    echo "$count"
}

update_claude_config() {
    log_step "Actualizando configuración..."

    local install_path
    install_path=$(get_install_path)

    # Update CLAUDE.md (it's a copy, not symlink)
    if [ -f "$install_path/CLAUDE.md" ]; then
        cp "$install_path/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
        log_info "CLAUDE.md actualizado"
    fi

    # Get version info
    local new_version
    new_version=$(get_new_version)

    # Write config file
    {
        echo "# Claude Code Auto-Skills Configuration"
        echo "INSTALL_DATE=\"$(date +%Y-%m-%d)\""
        echo "INSTALL_PATH=\"${install_path}\""
        echo "VERSION=\"${new_version}\""
        echo "MODE=\"direct-overwrite\""
        echo "UPDATE_DATE=\"$(date '+%Y-%m-%d %H:%M:%S')\""
    } > "$CONFIG_FILE"

    log_info "Configuración actualizada"
}

show_changelog() {
    local old_version="$1"
    local new_version="$2"

    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}                     📋 RESUMEN DE CAMBIOS${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "   ${BLUE}Versión anterior:${NC} ${YELLOW}${old_version}${NC}"
    echo -e "   ${BLUE}Versión nueva:${NC}    ${GREEN}${new_version}${NC}"
    echo ""

    # Show skill count
    local skill_count
    skill_count=$(count_skills)

    echo -e "   ${GREEN}✓${NC} Total de skills disponibles: ${BOLD}${YELLOW}${skill_count}${NC}"
    echo ""
}

print_success_footer() {
    local install_path
    install_path=$(get_install_path)

    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}                  ✅ ACTUALIZACIÓN COMPLETADA${NC}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${BOLD}${BLUE}📚 Skills Disponibles:${NC}"
    echo ""

    # Categorize skills
    local -a backend=()
    local -a frontend=()
    local -a testing=()
    local -a quality=()
    local -a api=()
    local -a tools=()

    if [ -d "$install_path/skills" ]; then
        for skill_file in "$install_path/skills"/*.md; do
            # Skip if doesn't exist or is README
            if [ ! -f "$skill_file" ] || [[ "$(basename "$skill_file")" == "README.md" ]]; then
                continue
            fi

            local skill_name
            skill_name=$(basename "$skill_file" .md)

            case "$skill_name" in
                php-symfony|laravel|arquitectura-hexagonal|solid|clean-code)
                    backend+=("$skill_name")
                    ;;
                react|typescript|twig|volt)
                    frontend+=("$skill_name")
                    ;;
                playwright|pom|cucumber)
                    testing+=("$skill_name")
                    ;;
                phpstan|swagger)
                    quality+=("$skill_name")
                    ;;
                openai)
                    api+=("$skill_name")
                    ;;
                python|bash-scripts)
                    tools+=("$skill_name")
                    ;;
            esac
        done
    fi

    # Display categorized
    if [ ${#backend[@]} -gt 0 ]; then
        echo -e "   ${CYAN}▸ Backend & Arquitectura (${#backend[@]}):${NC}"
        for skill in "${backend[@]}"; do
            echo -e "     ${GREEN}✓${NC} $skill"
        done
        echo ""
    fi

    if [ ${#frontend[@]} -gt 0 ]; then
        echo -e "   ${CYAN}▸ Frontend & Templates (${#frontend[@]}):${NC}"
        for skill in "${frontend[@]}"; do
            echo -e "     ${GREEN}✓${NC} $skill"
        done
        echo ""
    fi

    if [ ${#testing[@]} -gt 0 ]; then
        echo -e "   ${CYAN}▸ Testing (${#testing[@]}):${NC}"
        for skill in "${testing[@]}"; do
            echo -e "     ${GREEN}✓${NC} $skill"
        done
        echo ""
    fi

    if [ ${#quality[@]} -gt 0 ]; then
        echo -e "   ${CYAN}▸ Quality & Documentation (${#quality[@]}):${NC}"
        for skill in "${quality[@]}"; do
            echo -e "     ${GREEN}✓${NC} $skill"
        done
        echo ""
    fi

    if [ ${#api[@]} -gt 0 ]; then
        echo -e "   ${CYAN}▸ API & Integration (${#api[@]}):${NC}"
        for skill in "${api[@]}"; do
            echo -e "     ${GREEN}✓${NC} $skill"
        done
        echo ""
    fi

    if [ ${#tools[@]} -gt 0 ]; then
        echo -e "   ${CYAN}▸ Languages & Tools (${#tools[@]}):${NC}"
        for skill in "${tools[@]}"; do
            echo -e "     ${GREEN}✓${NC} $skill"
        done
        echo ""
    fi

    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "   ${MAGENTA}💡 Tip:${NC} Los skills se actualizan automáticamente gracias a los"
    echo -e "   symlinks. Solo ejecuta ${CYAN}bash update.sh${NC} para sincronizar."
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
    echo -e "   ${BOLD}${GREEN}🚀 Claude Code listo con tus skills actualizados${NC}"
    echo ""
}

rollback() {
    log_error "Error durante la actualización"

    if [ -d "$BACKUP_DIR" ]; then
        log_warning "Restaurando desde backup..."

        [ -f "$BACKUP_DIR/CLAUDE.md" ] && cp "$BACKUP_DIR/CLAUDE.md" "$CLAUDE_DIR/"
        [ -f "$BACKUP_DIR/.skills-config" ] && cp "$BACKUP_DIR/.skills-config" "$CLAUDE_DIR/"

        log_info "Backup restaurado"
    fi

    exit 1
}

# Main
main() {
    trap rollback ERR

    print_header
    check_installation

    local current_version
    current_version=$(get_current_version)

    echo -e "   ${BLUE}Versión instalada:${NC} ${YELLOW}${current_version}${NC}"
    echo ""

    backup_current
    update_repository
    update_claude_config

    local new_version
    new_version=$(get_new_version)

    show_changelog "$current_version" "$new_version"
    print_success_footer
}

main "$@"
