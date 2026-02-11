# 🧠 Claude Code Auto-Skills

> **⚠️ PROYECTO ARCHIVADO - POC EXITOSA**
>
> Este proyecto fue una **Proof of Concept exitosa** que funcionó perfectamente y demostró el concepto de skills auto-cargables para Claude Code.
>
> **Estado**: Archivado (2026-02-12)
> **Razón**: El proyecto evolucionó hacia un enfoque más simple y poderoso basado en descubrimientos sobre los internals de Claude Code.
> **Código**: 100% funcional, documentado y testeado.
> **Instalación**: Disponible pero sin mantenimiento activo.
>
> 📚 **Este proyecto sirvió como base de aprendizaje y exploración**. Todos los commits, tests y documentación se mantienen como referencia.

---

> Sistema inteligente de skills auto-cargables para Claude Code que detecta tu stack tecnológico y carga automáticamente el contexto relevante.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-8A2BE2)](https://claude.ai/code)

---

## ✨ Features

- 🎯 **Auto-detección inteligente**: Analiza tu proyecto y sugiere skills relevantes
- 💾 **Auto-configuración**: Primera vez configura, después 100% automático
- 🔧 **Multi-lenguaje**: PHP/Symfony, Python, TypeScript, Playwright, Bash, OpenAI
- 💰 **Ahorro de tokens**: Solo carga lo que necesitas por proyecto
- 🔄 **Auto-actualizable**: Los skills se mantienen actualizados con Context7
- 🚀 **Zero-config**: Funciona out-of-the-box después de instalación
- 📚 **Reutilizable**: Una configuración para todos tus proyectos

---

## 📋 Requisitos

### Imprescindible
- **Claude Code CLI** instalado ([Instalación oficial](https://claude.ai/code))

### Recomendado (pero no obligatorio)
- **Context7 MCP** configurado en Claude Code
  - Permite actualización automática de skills con documentación oficial actualizada
  - Sin Context7, los skills funcionarán perfectamente con la documentación incluida en la versión instalada (actualizada a la fecha de publicación)

---

## 🚀 Quick Start

### Instalación

```bash
# Opción 1: Script de instalación automática (recomendado)
curl -sSL https://raw.githubusercontent.com/joseguillermomoreu-gif/claude-code-auto-skills/master/install.sh | bash

# Opción 2: Instalación manual
git clone https://github.com/joseguillermomoreu-gif/claude-code-auto-skills.git
cd claude-code-auto-skills
./install.sh
```

### Verificar instalación

```bash
ls ~/.claude/skills/
# Deberías ver: python.md, php-symfony.md, typescript.md, etc.

ls ~/.claude/CLAUDE.md
# Debería existir
```

### 🔄 Actualización

Si ya tienes instalado claude-code-auto-skills y quieres actualizar a la última versión:

```bash
# Opción 1: Script de actualización automática (recomendado)
cd /ruta/donde/clonaste/claude-code-auto-skills
bash update.sh

# Opción 2: Actualización manual
git pull origin master
bash install.sh
```

**¿Qué hace update.sh?**
- ✅ Auto-detecta tu versión actual instalada
- ✅ Descarga última versión del repositorio (git pull)
- ✅ Crea backup de seguridad antes de actualizar
- ✅ Actualiza CLAUDE.md y configuración
- ✅ Muestra changelog con nuevos skills añadidos
- ✅ Lista completa de skills disponibles al finalizar

**Ejemplo de salida:**

```
╔════════════════════════════════════════════════════════════════════════════╗
║                    🔄 Actualizador de Claude Code Auto-Skills              ║
╚════════════════════════════════════════════════════════════════════════════╝

   Versión instalada: v1.0.0

→ Verificando instalación existente...
✓ Instalación encontrada

→ Actualizando desde repositorio...
✓ Repositorio actualizado

╔════════════════════════════════════════════════════════════════════════════╗
║                           📋 RESUMEN DE CAMBIOS                            ║
╚════════════════════════════════════════════════════════════════════════════╝

   Versión anterior: v1.0.0
   Versión actual:   v1.1.0

   ✓ Total de skills disponibles: 17

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Actualización Completada
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   ✨ Gracias por usar Claude Code Auto-Skills ✨

   Desarrollado con 💙 por José Guillermo Moreu
```

---

## 🎯 Cómo Funciona

### Primera vez en un proyecto

1. Abres Claude Code en tu proyecto:
   ```bash
   cd ~/mi-proyecto-symfony
   claude
   ```

2. En tu primer mensaje, Claude detecta automáticamente tu stack:
   ```
   > Usuario: "Ayúdame a refactorizar el UserController"

   🔍 Analizando proyecto...

   📂 Detectado:
   ✓ composer.json (Symfony)
   ✓ tsconfig.json (TypeScript)

   📚 Skills disponibles:
   1. php-symfony.md - Arquitectura hexagonal, Doctrine
   2. typescript.md - Convenciones TypeScript

   ¿Cuáles quieres cargar? (1,2 o 'todos'):
   ```

3. Eliges qué cargar y Claude crea `MEMORY.md` automáticamente

4. **Próximas sesiones**: 100% automático, sin preguntas

### Durante la sesión

Puedes añadir o remover skills dinámicamente:

```bash
> "carga también python.md"
📚 Cargando skill adicional: python.md
¿Actualizar MEMORY.md para próximas sesiones? (s/n)

> "remueve typescript"
✅ Removido typescript.md de la sesión

> "lista skills"
📚 Skills Activos: php-symfony.md
📦 Skills Disponibles: python.md, typescript.md, playwright.md, ...
```

---

## 📚 Skills Incluidos (20 total)

### Backend & Arquitectura (5 skills)

#### **php-symfony.md**
Symfony framework, Doctrine ORM, arquitectura hexagonal, testing.

#### **laravel.md**
Laravel framework, Eloquent ORM, Blade templating, Artisan.

#### **arquitectura-hexagonal.md**
Ports & Adapters pattern, Domain-Driven Design, clean architecture.

#### **solid.md**
SOLID principles con ejemplos prácticos en PHP y Python.

#### **clean-code.md**
Clean Code practices, refactoring, naming conventions, best practices.

---

### Frontend & Templates (4 skills)

#### **react.md**
React con Hooks, TypeScript, performance optimization, modern patterns.

#### **typescript.md**
Types, generics, utility types, strict mode, advanced patterns.

#### **twig.md**
Twig templating engine para Symfony, filters, macros, extensions.

#### **volt.md**
Volt templating para Phalcon/Symfony, sintaxis y configuración.

---

### Testing (3 skills)

#### **playwright.md**
Playwright E2E testing, configuración, fixtures, debugging.

#### **pom.md**
Page Object Model pattern (deep dive), locator strategies, wait patterns.

#### **cucumber.md**
BDD con Gherkin, Cucumber.js + Playwright, step definitions, hooks.

---

### Quality & Documentation (2 skills)

#### **phpstan.md**
Static analysis con PHPStan levels 0-9, baseline management, CI/CD integration.

#### **swagger.md**
OpenAPI/Swagger documentation, Symfony NelmioApiDocBundle, PHP 8 attributes.

---

### API & LLMs (2 skills)

#### **openai.md**
OpenAI API patterns con Python, streaming, embeddings, function calling.

#### **llms.md**
Large Language Models, prompt engineering, integración, costos, testing, proveedores.

---

### CI/CD (2 skills)

#### **github-actions.md**
GitHub Actions workflows, matrix builds, caché, secrets, reusable workflows, best practices.

#### **gitlab-ci.md**
GitLab CI/CD pipelines, stages, jobs, artifacts, cache, templates, deployment.

---

### Languages & Tools (2 skills)

#### **python.md**
Python para developers PHP, equivalencias, type hints, pytest, poetry.

#### **bash-scripts.md**
Bash scripting robusto, logging, error handling, deployment automation.

---

## 🎓 Ejemplos de Uso

### Ejemplo 1: Proyecto Symfony + TypeScript

```bash
cd ~/mi-ecommerce
claude

> "Necesito añadir validación al OrderController"

🔍 Analizando proyecto...
📂 Detectado: composer.json, tsconfig.json

📚 Skills disponibles:
1. php-symfony.md
2. typescript.md

¿Cuáles quieres cargar? todos

✅ Skills cargados: php-symfony, typescript
💾 MEMORY.md creado

# Claude ahora trabaja con contexto de:
# - Arquitectura hexagonal
# - Doctrine patterns
# - TypeScript conventions
```

### Ejemplo 2: Proyecto Python + OpenAI

```bash
cd ~/chatbot-ai
claude

> "Ayúdame a crear un chatbot con OpenAI"

🔍 Analizando proyecto...
📂 Detectado: pyproject.toml, requirements.txt (openai)

📚 Skills disponibles:
1. python.md
2. openai.md

¿Cuáles quieres cargar? todos

✅ Skills cargados: python, openai
💾 MEMORY.md creado

# Claude ahora conoce:
# - Python best practices
# - OpenAI API patterns
# - Error handling para LLMs
```

### Ejemplo 3: Proyecto existente (MEMORY.md ya existe)

```bash
cd ~/mi-proyecto  # Ya tiene MEMORY.md

claude

> "Refactoriza el UserService"

📚 Skills cargados: php-symfony, typescript
# Sin preguntar nada, 100% automático
```

---

## 🔧 Personalización

### Modificar tu perfil

Edita `~/.claude/CLAUDE.md`:

```bash
vim ~/.claude/CLAUDE.md

# Modifica:
# - Stack tecnológico
# - Preferencias de código
# - Naming conventions
# - Filosofía de trabajo
```

### Añadir skill personalizado

1. Crea tu skill:
   ```bash
   vim ~/.claude/skills/mi-skill.md
   ```

2. Sigue la estructura de skills existentes:
   - Descripción clara
   - Ejemplos prácticos
   - Convenciones
   - Sección de auto-mantenimiento

3. Añádelo a la detección automática en `CLAUDE.md`

---

## 📖 Documentación

- [Workflow de Desarrollo](docs/WORKFLOW.md) - Gitflow, TDD, CI/CD
- [Framework de Testing](tests/README.md) - Cómo se testeó el proyecto

---

## 🏁 Estado del Proyecto

**Versión final**: v1.3.0
**Estado**: POC Exitosa - Archivada
**Fecha de cierre**: 2026-02-12

### ✅ Logros Completados
- [x] Skills base (PHP, Python, TypeScript, Playwright, Bash, OpenAI) - v1.0.0
- [x] Sistema de auto-detección - v1.0.0
- [x] Auto-configuración con MEMORY.md - v1.0.0
- [x] Skills adicionales: Laravel, React, PHPStan, Swagger - v1.1.0
- [x] Skills de arquitectura: Hexagonal, SOLID, Clean Code - v1.1.0
- [x] Skills de testing: POM, Cucumber - v1.1.0
- [x] Skills de templates: Twig, Volt - v1.1.0
- [x] Script de actualización automática (update.sh) - v1.2.0
- [x] Skills LLMs y CI/CD: GitHub Actions, GitLab CI - v1.2.3
- [x] Workflow completo: Gitflow, TDD, CI/CD - v1.3.0

**Total**: 20 skills especializados + infraestructura completa de desarrollo

### 🎓 Aprendizajes Clave

Durante el desarrollo de este proyecto se descubrieron detalles importantes sobre Claude Code que llevaron a una evolución del concepto:

- Claude Code tiene un sistema nativo de memoria en `~/.claude/projects/`
- Los skills on-the-fly con Context7 son más eficientes que skills estáticos
- Un super-prompt configurable es más flexible que un sistema instalable
- La auto-configuración interactiva elimina la necesidad de instalación manual

Estos descubrimientos inspiraron la evolución hacia un nuevo enfoque más simple y poderoso.

---

## 💡 FAQ

### ¿Es compatible con cualquier versión de Claude Code?

Sí, funciona con Claude Code CLI. Los skills son archivos markdown que Claude lee y aplica.

### ¿Puedo usar solo algunos skills?

Sí, puedes elegir qué cargar en cada proyecto. Solo pagarás tokens por los skills activos.

### ¿Los skills se actualizan automáticamente?

Si tienes Context7 MCP configurado, Claude Code puede actualizar los skills con la documentación oficial más reciente. Sin Context7, los skills incluyen documentación actualizada a la fecha de la versión instalada.

### ¿Puedo modificar los skills?

Sí, son archivos markdown en `~/.claude/skills/`. Puedes editarlos libremente.

### ¿Funciona sin conexión a internet?

Los skills sí funcionan offline. La actualización automática con Context7 requiere conexión.

### ¿Cuántos tokens consume?

Depende de qué skills cargues. Ejemplo:
- 1 skill pequeño: ~2-4K tokens
- 3 skills: ~10-15K tokens
- Solo cargas lo que necesitas por proyecto

### ¿Por qué está archivado si funcionaba?

El proyecto funcionó perfectamente como POC. Durante su desarrollo se descubrieron detalles sobre los internals de Claude Code que permitieron idear un enfoque más simple y poderoso. Este proyecto queda como referencia técnica y base de aprendizaje.

---

## 📊 Estadísticas del Proyecto

- **20 skills especializados** cubriendo backend, frontend, testing, quality, CI/CD y tools
- **Auto-actualización** con Context7 MCP para documentación siempre actualizada
- **100% auto-configurable** después del primer uso
- **Script de actualización** incluido (update.sh)
- **MIT License** - Úsalo libremente

---

## 👏 Créditos

Creado por [José Guillermo Moreu](https://github.com/joseguillermomoreu-gif)

Inspirado en la necesidad de mantener contexto consistente entre proyectos usando Claude Code.

---

## 📄 License

MIT License - ver [LICENSE](LICENSE) para detalles.

---

## 🔗 Links

- [Claude Code](https://claude.ai/code) - CLI oficial de Anthropic
- [Context7](https://context7.com) - Documentación actualizada para LLMs
- [Issues](https://github.com/joseguillermomoreu-gif/claude-code-auto-skills/issues) - Reportar bugs o sugerencias

---

**⭐ Este proyecto sirvió como POC y base de aprendizaje para proyectos futuros**

Código disponible como referencia técnica. No se aceptan nuevas contribuciones.
