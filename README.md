# 🧠 Claude Code Auto-Skills

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

## 🚀 Quick Start

### Instalación

```bash
# Opción 1: Script de instalación automática (recomendado)
curl -sSL https://raw.githubusercontent.com/joseguillermomoreu-gif/claude-code-auto-skills/main/install.sh | bash

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

## 📚 Skills Incluidos

### Backend

#### **php-symfony.md**
Arquitectura hexagonal, Doctrine, testing, Domain-driven Design.

**Ideal para**:
- Proyectos Symfony 7.x+
- Arquitectura hexagonal (Ports & Adapters)
- Domain-driven Design
- PHPUnit + Behat

**Contenido**:
- Estructura de capas (Domain/Application/Infrastructure)
- Entities y Value Objects
- Repository pattern
- Testing estratégico
- Convenciones Symfony

---

#### **python.md**
Guía para developers PHP aprendiendo Python.

**Ideal para**:
- Developers PHP/Symfony migrando a Python
- Proyectos Python 3.12+
- Poetry para gestión de dependencias

**Contenido**:
- Tabla de equivalencias PHP ↔ Python
- Type hints (similar a PHP 8)
- Pytest (vs PHPUnit)
- Estructuras de proyecto
- PEP 8 conventions

---

### Frontend

#### **typescript.md**
Convenciones, types, generics, patterns.

**Ideal para**:
- Proyectos TypeScript 5.x+
- React, Vue, Angular
- Type safety estricto

**Contenido**:
- Types vs Interfaces
- Utility Types (Partial, Pick, Omit, Record)
- Generics avanzados
- Type Guards
- Discriminated Unions
- Configuración tsconfig.json

---

### Testing

#### **playwright.md**
Page Object Model estricto, fixtures, best practices E2E.

**Ideal para**:
- Testing E2E con Playwright
- Proyectos TypeScript
- Arquitectura POM

**Contenido**:
- Page Object Model (POM) estricto
- Fixtures reutilizables
- Selectores best practices
- Assertions comunes
- Debugging strategies
- Configuración playwright.config.ts

---

### AI/ML

#### **openai.md**
Patrones para OpenAI API con Python.

**Ideal para**:
- Integración OpenAI API
- Proyectos Python con LLMs
- Chatbots, embeddings, function calling

**Contenido**:
- Chat completions
- Streaming responses
- Embeddings y búsqueda semántica
- Function calling (tool use)
- Error handling robusto
- Rate limiting
- Conversation history

---

### DevOps

#### **bash-scripts.md**
Scripts robustos con logging y error handling.

**Ideal para**:
- Scripts de deploy
- Automatización
- CI/CD pipelines

**Contenido**:
- Template estándar con strict mode
- Logging con colores
- Error handling y retry logic
- Parsing de argumentos
- Cleanup automático
- Best practices

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

Ver [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) para guía completa.

---

## 📖 Documentación

- [Guía de Contribución](docs/CONTRIBUTING.md) - Cómo contribuir al proyecto
- [Personalización](docs/CUSTOMIZATION.md) - Cómo personalizar skills
- [Arquitectura](docs/ARCHITECTURE.md) - Cómo funciona el sistema

---

## 🤝 Contributing

¡Contribuciones bienvenidas! Este proyecto mejora con la experiencia de la comunidad.

**Formas de contribuir**:
- 🐛 Reportar bugs o información desactualizada
- ✨ Proponer nuevos skills (Go, Rust, Java, etc.)
- 📝 Mejorar documentación
- 🔧 Optimizar skills existentes
- 💡 Compartir tus mejores prácticas

Lee [CONTRIBUTING.md](docs/CONTRIBUTING.md) para más detalles.

---

## 🗺️ Roadmap

- [x] Skills base (PHP, Python, TypeScript, Playwright, Bash, OpenAI)
- [x] Sistema de auto-detección
- [x] Auto-configuración con MEMORY.md
- [ ] Skills adicionales: Go, Rust, Java, C#
- [ ] Skills de frameworks: Laravel, Django, NestJS, Spring
- [ ] Skills de infraestructura: Docker, Kubernetes, Terraform
- [ ] Web UI para gestionar skills
- [ ] Marketplace de skills comunitarios
- [ ] Integración con GitHub Actions

---

## 💡 FAQ

### ¿Es compatible con cualquier versión de Claude Code?

Sí, funciona con Claude Code CLI. Los skills son archivos markdown que Claude lee y aplica.

### ¿Puedo usar solo algunos skills?

Sí, puedes elegir qué cargar en cada proyecto. Solo pagarás tokens por los skills activos.

### ¿Los skills se actualizan automáticamente?

Claude Code detecta cuando hay información desactualizada y pregunta si quieres actualizar, usando Context7 para obtener la última documentación.

### ¿Puedo modificar los skills?

Sí, son archivos markdown en `~/.claude/skills/`. Puedes editarlos libremente.

### ¿Funciona sin conexión a internet?

Los skills sí funcionan offline. La actualización automática con Context7 requiere conexión.

### ¿Cuántos tokens consume?

Depende de qué skills cargues. Ejemplo:
- 1 skill pequeño: ~2-4K tokens
- 3 skills: ~10-15K tokens
- Solo cargas lo que necesitas por proyecto

---

## 📊 Estadísticas del Proyecto

- **6 skills base** cubriendo los stacks más comunes
- **15KB** de configuración inteligente
- **100% auto-configurable** después del primer uso
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

**⭐ Si este proyecto te ayuda, considera darle una estrella en GitHub**

¿Preguntas? Abre un [issue](https://github.com/joseguillermomoreu-gif/claude-code-auto-skills/issues) o contacta en [Twitter/X](https://twitter.com/tu-usuario)
