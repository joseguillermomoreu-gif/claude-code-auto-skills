#!/usr/bin/env bash
#
# Claude Code Auto-Skills - Installation Script
# Instala el sistema de skills auto-cargables para Claude Code
#

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Defaults
readonly DEFAULT_INSTALL_PATH="$HOME/claude-code-auto-skills"
readonly CLAUDE_DIR="$HOME/.claude"
readonly CONFIG_FILE="$CLAUDE_DIR/.skills-config"
readonly BACKUP_PREFIX=".backup"

# Script location
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Functions
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

print_header() {
    clear
    echo -e "${MAGENTA}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║     ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗               ║
║    ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝               ║
║    ██║     ██║     ███████║██║   ██║██║  ██║█████╗                 ║
║    ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝                 ║
║    ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗               ║
║     ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝               ║
║                                                                      ║
║              ██████╗ ██████╗ ██████╗ ███████╗                       ║
║             ██╔════╝██╔═══██╗██╔══██╗██╔════╝                       ║
║             ██║     ██║   ██║██║  ██║█████╗                         ║
║             ██║     ██║   ██║██║  ██║██╔══╝                         ║
║             ╚██████╗╚██████╔╝██████╔╝███████╗                       ║
║              ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝                       ║
║                                                                      ║
║                    🧠 Auto-Skills Framework                          ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Sistema inteligente de skills auto-cargables para Claude Code${NC}"
    echo -e "${CYAN}Detecta tu stack y carga contexto relevante automáticamente${NC}"
    echo ""
    echo -e "${BLUE}Stack soportado:${NC} PHP/Symfony · Python · TypeScript · Playwright · OpenAI · Bash"
    echo -e "${BLUE}Autor:${NC} José Guillermo Moreu (@joseguillermomoreu-gif)"
    echo -e "${BLUE}License:${NC} MIT"
    echo -e "${BLUE}Repo:${NC} github.com/joseguillermomoreu-gif/claude-code-auto-skills"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

check_dependencies() {
    log_step "Verificando dependencias..."

    local missing_deps=()

    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi

    if ! command -v ln &> /dev/null; then
        missing_deps+=("coreutils (ln)")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Dependencias faltantes: ${missing_deps[*]}"
        log_error "Por favor, instálalas y vuelve a ejecutar el script"
        exit 1
    fi

    log_info "Dependencias OK"
}

choose_install_mode() {
    log_step "Modo de instalación"

    echo ""
    echo -e "${BLUE}🔧 ¿Qué modo de instalación prefieres?${NC}"
    echo ""
    echo -e "   ${GREEN}1. COPY${NC} (Recomendado)"
    echo -e "      • CLAUDE.md copiado a ~/.claude/ (archivo real)"
    echo -e "      • Skills como symlinks (editables y comiteables)"
    echo -e "      ${CYAN}→ Claude Code lee el CLAUDE.md automáticamente${NC}"
    echo ""
    echo -e "   ${YELLOW}2. SYMLINK${NC} (Desarrollo)"
    echo -e "      • Todo son symlinks al repo"
    echo -e "      • Para desarrollo del framework"
    echo ""
    read -p "   Modo (1/2): " mode_choice

    case $mode_choice in
        2)
            INSTALL_MODE="symlink"
            log_info "Modo seleccionado: ${YELLOW}SYMLINK${NC}"
            ;;
        *)
            INSTALL_MODE="copy"
            log_info "Modo seleccionado: ${GREEN}COPY${NC}"
            ;;
    esac
    echo ""
}

get_install_path() {
    log_step "Configuración de instalación"

    echo ""
    echo -e "${BLUE}📂 ¿Dónde quieres instalar el proyecto?${NC}"
    echo -e "   ${CYAN}(Pulsa Enter para usar el default)${NC}"
    echo ""
    echo -e "   Default: ${YELLOW}$DEFAULT_INSTALL_PATH${NC}"
    read -p "   Path: " user_path

    if [ -z "$user_path" ]; then
        INSTALL_PATH="$DEFAULT_INSTALL_PATH"
    else
        # Expand ~ to home directory
        INSTALL_PATH="${user_path/#\~/$HOME}"
    fi

    # Convert to absolute path
    INSTALL_PATH="$(cd "$(dirname "$INSTALL_PATH")" 2>/dev/null && pwd)/$(basename "$INSTALL_PATH")" || INSTALL_PATH="$INSTALL_PATH"

    echo ""
    log_info "Path de instalación: ${YELLOW}$INSTALL_PATH${NC}"
}

check_existing_installation() {
    if [ -f "$CONFIG_FILE" ]; then
        log_warning "Instalación existente detectada"

        source "$CONFIG_FILE"
        echo ""
        echo -e "   Instalación actual: ${YELLOW}$SKILLS_REPO_PATH${NC}"
        echo -e "   Instalado: ${YELLOW}$INSTALL_DATE${NC}"
        echo ""

        read -p "¿Reinstalar/actualizar? (s/n): " confirm
        if [[ ! "$confirm" =~ ^[sS]$ ]]; then
            echo ""
            log_info "Instalación cancelada"
            exit 0
        fi

        # Cleanup existing symlinks
        cleanup_symlinks
    fi
}

backup_existing_files() {
    log_step "Verificando archivos existentes en ~/.claude/..."

    local needs_backup=false
    local backup_dir="$CLAUDE_DIR/$BACKUP_PREFIX-$(date +%Y%m%d-%H%M%S)"

    # Check for existing files (not symlinks)
    if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
        needs_backup=true
    fi

    if [ -d "$CLAUDE_DIR/skills" ] && [ ! -L "$CLAUDE_DIR/skills" ]; then
        needs_backup=true
    fi

    if [ -d "$CLAUDE_DIR/templates" ] && [ ! -L "$CLAUDE_DIR/templates" ]; then
        needs_backup=true
    fi

    if [ "$needs_backup" = true ]; then
        log_warning "Archivos existentes detectados en ~/.claude/"
        echo ""
        echo "   Opciones:"
        echo "   1. Hacer backup y continuar (recomendado)"
        echo "   2. Sobrescribir (perderás tu configuración actual)"
        echo "   3. Cancelar instalación"
        echo ""
        read -p "   ¿Qué prefieres? (1/2/3): " choice

        case $choice in
            1)
                mkdir -p "$backup_dir"

                [ -f "$CLAUDE_DIR/CLAUDE.md" ] && cp "$CLAUDE_DIR/CLAUDE.md" "$backup_dir/"
                [ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$backup_dir/"
                [ -d "$CLAUDE_DIR/templates" ] && cp -r "$CLAUDE_DIR/templates" "$backup_dir/"

                log_info "Backup creado en: ${YELLOW}$backup_dir${NC}"
                ;;
            2)
                log_warning "Sobrescribiendo archivos existentes..."
                ;;
            3)
                log_info "Instalación cancelada"
                exit 0
                ;;
            *)
                log_error "Opción inválida"
                exit 1
                ;;
        esac
    else
        log_info "No hay archivos existentes, continuando..."
    fi
}

clone_or_use_existing_repo() {
    log_step "Obteniendo repositorio..."

    if [ -d "$INSTALL_PATH/.git" ]; then
        log_info "Repositorio ya existe en $INSTALL_PATH"

        cd "$INSTALL_PATH"

        # Check if it's our repo
        local remote_url
        remote_url=$(git config --get remote.origin.url 2>/dev/null || echo "")

        if [[ "$remote_url" == *"claude-code-auto-skills"* ]]; then
            log_info "Repositorio válido detectado"

            read -p "¿Actualizar desde remoto? (s/n): " update
            if [[ "$update" =~ ^[sS]$ ]]; then
                git pull origin main || log_warning "No se pudo actualizar (no hay problema)"
            fi
        else
            log_warning "El directorio contiene otro repositorio"
        fi
    elif [ -d "$INSTALL_PATH" ] && [ "$(ls -A "$INSTALL_PATH")" ]; then
        log_error "El directorio $INSTALL_PATH ya existe y no está vacío"
        log_error "Por favor, elige otra ubicación o elimina el directorio"
        exit 1
    elif [ "$SCRIPT_DIR" != "$INSTALL_PATH" ]; then
        # We're running from a different location, need to clone/copy
        log_info "Copiando archivos a $INSTALL_PATH..."

        mkdir -p "$(dirname "$INSTALL_PATH")"

        if [ -d "$SCRIPT_DIR/.git" ]; then
            # Clone from current location
            git clone "$SCRIPT_DIR" "$INSTALL_PATH"
        else
            # Copy files
            cp -r "$SCRIPT_DIR" "$INSTALL_PATH"
        fi
    else
        log_info "Usando ubicación actual: $INSTALL_PATH"
    fi

    log_info "Repositorio listo en: ${YELLOW}$INSTALL_PATH${NC}"
}

cleanup_symlinks() {
    log_step "Limpiando symlinks anteriores..."

    [ -L "$CLAUDE_DIR/CLAUDE.md" ] && rm "$CLAUDE_DIR/CLAUDE.md"
    [ -L "$CLAUDE_DIR/skills" ] && rm "$CLAUDE_DIR/skills"
    [ -L "$CLAUDE_DIR/templates" ] && rm "$CLAUDE_DIR/templates"

    log_info "Limpieza completada"
}

install_files() {
    log_step "Instalando archivos..."

    mkdir -p "$CLAUDE_DIR"

    # Remove existing files/dirs (not symlinks, those were cleaned up)
    [ -f "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ] && rm "$CLAUDE_DIR/CLAUDE.md"
    [ -d "$CLAUDE_DIR/skills" ] && [ ! -L "$CLAUDE_DIR/skills" ] && rm -rf "$CLAUDE_DIR/skills"
    [ -d "$CLAUDE_DIR/templates" ] && [ ! -L "$CLAUDE_DIR/templates" ] && rm -rf "$CLAUDE_DIR/templates"

    if [ "$INSTALL_MODE" = "copy" ]; then
        # Modo COPY: CLAUDE.md copiado, resto symlinks
        cp "$INSTALL_PATH/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
        ln -sf "$INSTALL_PATH/skills" "$CLAUDE_DIR/skills"
        ln -sf "$INSTALL_PATH/templates" "$CLAUDE_DIR/templates"

        log_info "Archivos instalados (modo COPY):"
        echo -e "   ${GREEN}~/.claude/CLAUDE.md${NC} ← ${YELLOW}$INSTALL_PATH/CLAUDE.md${NC} (copiado)"
        echo -e "   ${CYAN}~/.claude/skills${NC} → ${YELLOW}$INSTALL_PATH/skills${NC} (symlink)"
        echo -e "   ${CYAN}~/.claude/templates${NC} → ${YELLOW}$INSTALL_PATH/templates${NC} (symlink)"
    else
        # Modo SYMLINK: Todo symlinks
        ln -sf "$INSTALL_PATH/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
        ln -sf "$INSTALL_PATH/skills" "$CLAUDE_DIR/skills"
        ln -sf "$INSTALL_PATH/templates" "$CLAUDE_DIR/templates"

        log_info "Symlinks creados (modo SYMLINK):"
        echo -e "   ${CYAN}~/.claude/CLAUDE.md${NC} → ${YELLOW}$INSTALL_PATH/CLAUDE.md${NC}"
        echo -e "   ${CYAN}~/.claude/skills${NC} → ${YELLOW}$INSTALL_PATH/skills${NC}"
        echo -e "   ${CYAN}~/.claude/templates${NC} → ${YELLOW}$INSTALL_PATH/templates${NC}"
    fi
}

save_config() {
    log_step "Guardando configuración..."

    cat > "$CONFIG_FILE" << EOF
# Claude Code Auto-Skills Configuration
# Generated: $(date)
SKILLS_REPO_PATH="$INSTALL_PATH"
SKILLS_VERSION="1.0.0"
INSTALL_DATE="$(date +%Y-%m-%d)"
INSTALL_MODE="$INSTALL_MODE"
EOF

    log_info "Configuración guardada en: ${YELLOW}$CONFIG_FILE${NC}"
}

verify_installation() {
    log_step "Verificando instalación..."

    local errors=0

    if [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
        log_error "CLAUDE.md symlink no encontrado"
        ((errors++))
    fi

    if [ ! -L "$CLAUDE_DIR/skills" ]; then
        log_error "skills/ symlink no encontrado"
        ((errors++))
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Archivo de configuración no encontrado"
        ((errors++))
    fi

    # Check skills
    local skill_count=0
    for skill in "$INSTALL_PATH/skills"/*.md; do
        if [ -f "$skill" ]; then
            ((skill_count++))
        fi
    done

    if [ "$skill_count" -eq 0 ]; then
        log_error "No se encontraron skills"
        ((errors++))
    fi

    if [ "$errors" -gt 0 ]; then
        log_error "Instalación completada con errores"
        return 1
    fi

    log_info "Verificación exitosa"
    log_info "Skills instalados: ${YELLOW}$skill_count${NC}"
}

print_success() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ ¡Instalación completada exitosamente!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${BLUE}📚 Skills instalados:${NC}"
    for skill in "$INSTALL_PATH/skills"/*.md; do
        if [ -f "$skill" ]; then
            echo -e "   ${GREEN}✓${NC} $(basename "$skill")"
        fi
    done

    echo ""
    echo -e "${BLUE}📂 Ubicaciones:${NC}"
    echo -e "   Proyecto: ${YELLOW}$INSTALL_PATH${NC}"
    echo -e "   Config: ${YELLOW}$CONFIG_FILE${NC}"

    echo ""
    echo -e "${BLUE}💡 Próximos pasos:${NC}"
    echo ""
    echo -e "   ${CYAN}1.${NC} Personaliza tu perfil:"
    echo -e "      ${YELLOW}vim $INSTALL_PATH/CLAUDE.md${NC}"
    echo ""
    echo -e "   ${CYAN}2.${NC} Edita skills si lo necesitas:"
    echo -e "      ${YELLOW}vim $INSTALL_PATH/skills/python.md${NC}"
    echo ""
    echo -e "   ${CYAN}3.${NC} Usa Claude Code en cualquier proyecto:"
    echo -e "      ${YELLOW}cd ~/mi-proyecto && claude${NC}"
    echo ""
    echo -e "   ${CYAN}4.${NC} Actualizar en el futuro:"
    echo -e "      ${YELLOW}cd $INSTALL_PATH && git pull${NC}"
    echo -e "      ${YELLOW}# O usa: ./update.sh${NC}"
    echo ""

    echo -e "${GREEN}🚀 ¡Todo listo para usar!${NC}"
    echo ""
}

rollback() {
    log_error "Error durante la instalación, haciendo rollback..."

    cleanup_symlinks
    [ -f "$CONFIG_FILE" ] && rm "$CONFIG_FILE"

    log_info "Rollback completado"
    exit 1
}

# Main installation flow
main() {
    # Trap errors for rollback
    trap rollback ERR

    print_header

    check_dependencies
    check_existing_installation
    choose_install_mode
    get_install_path
    backup_existing_files
    clone_or_use_existing_repo
    cleanup_symlinks
    install_files
    save_config
    verify_installation

    print_success
}

# Run main
main "$@"
