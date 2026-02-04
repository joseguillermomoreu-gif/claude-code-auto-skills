#!/usr/bin/env bash
#
# Script para inicializar el repositorio de GitHub
# Ejecuta esto para crear el repo y hacer el primer push
#

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

echo -e "${CYAN}🚀 Inicializando repositorio GitHub...${NC}"
echo ""

# Check if already initialized
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Repositorio git ya inicializado${NC}"
    read -p "¿Reiniciar? (s/n): " reinit
    if [[ "$reinit" =~ ^[sS]$ ]]; then
        rm -rf .git
    else
        echo "Usando repo existente"
    fi
fi

# Initialize git
if [ ! -d ".git" ]; then
    echo -e "${GREEN}✓${NC} Inicializando git..."
    git init
    git branch -M main
fi

# Add files
echo -e "${GREEN}✓${NC} Añadiendo archivos..."
git add .

# First commit
echo -e "${GREEN}✓${NC} Creando commit inicial..."
git commit -m "feat: initial commit - Claude Code Auto-Skills

Sistema inteligente de skills auto-cargables para Claude Code.

Features:
- 6 skills base (PHP/Symfony, Python, TypeScript, Playwright, OpenAI, Bash)
- Auto-detección de stack tecnológico
- Auto-configuración con MEMORY.md
- Path de instalación personalizable
- Sistema de symlinks no destructivo
- Scripts de instalación/actualización/desinstalación
- Documentación completa

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

echo ""
echo -e "${CYAN}📋 Siguiente paso:${NC}"
echo ""
echo "1. Crea el repositorio en GitHub:"
echo -e "   ${YELLOW}https://github.com/new${NC}"
echo ""
echo "   Nombre: ${YELLOW}claude-code-auto-skills${NC}"
echo "   Descripción: ${YELLOW}🧠 Sistema inteligente de skills auto-cargables para Claude Code${NC}"
echo "   Público: ${YELLOW}Sí${NC}"
echo "   NO inicializar con README (ya lo tenemos)"
echo ""
echo "2. Luego ejecuta estos comandos:"
echo ""
echo -e "   ${CYAN}git remote add origin https://github.com/joseguillermomoreu-gif/claude-code-auto-skills.git${NC}"
echo -e "   ${CYAN}git push -u origin main${NC}"
echo ""
echo -e "${GREEN}✅ Listo para push!${NC}"
