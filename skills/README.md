# 📚 Skills Disponibles

Este directorio contiene todos los skills auto-cargables para Claude Code.

## 🎯 Cómo Funcionan

Cuando trabajas en un proyecto, Claude Code detecta automáticamente qué skills son relevantes basándose en los archivos del proyecto (composer.json, pyproject.toml, etc.) y te pregunta cuáles quieres cargar.

---

## 📋 Lista de Skills

### Backend

#### **php-symfony.md**
```
Stack: Symfony 7.x + PHP 8.3
Arquitectura: Hexagonal (Ports & Adapters)
Testing: PHPUnit + Behat
```

**Contenido**:
- Estructura de capas (Domain/Application/Infrastructure)
- Entities y Value Objects inmutables
- Repository pattern con Doctrine
- Use Cases y DTOs
- Testing estratégico (Unit, Integration, E2E)
- Convenciones de naming
- Ejemplos completos de CRUD

**Cuándo se carga**: Detecta `composer.json` con Symfony

---

#### **python.md**
```
Versión: Python 3.12+
Enfoque: Para developers PHP aprendiendo Python
Gestión: Poetry
```

**Contenido**:
- Tabla de equivalencias PHP ↔ Python
- Type hints (similar a PHP 8)
- Dependency injection sin framework
- Testing con Pytest vs PHPUnit
- Estructuras de proyecto
- PEP 8 conventions
- Gestión de dependencias (Composer vs Poetry)

**Cuándo se carga**: Detecta `pyproject.toml` o `requirements.txt`

---

### Frontend

#### **typescript.md**
```
Versión: TypeScript 5.x
Configuración: strict mode
```

**Contenido**:
- Types vs Interfaces (cuándo usar cada uno)
- Utility Types (Partial, Pick, Omit, Record, ReturnType)
- Generics avanzados con constraints
- Type Guards y predicates
- Discriminated Unions (Tagged Unions)
- Async/Await patterns
- Readonly e immutability
- Testing con Vitest y tipos seguros

**Cuándo se carga**: Detecta `tsconfig.json` o `package.json` con TypeScript

---

### Testing

#### **playwright.md**
```
Framework: Playwright + TypeScript
Patrón: Page Object Model (POM) estricto
```

**Contenido**:
- Arquitectura POM obligatoria (NO selectores en tests)
- BasePage pattern con herencia
- Fixtures reutilizables
- Selectores best practices (data-testid > role > css)
- Naming conventions para pages y tests
- Assertions comunes
- Debugging strategies
- Configuración playwright.config.ts

**Cuándo se carga**: Detecta `playwright.config.ts`

---

### AI/ML

#### **openai.md**
```
SDK: openai-python (oficial)
Versión: 1.x
Lenguaje: Python
```

**Contenido**:
- Setup inicial con dotenv
- Chat completions (patrón base)
- Streaming responses para UIs
- Error handling robusto con retry + exponential backoff
- Embeddings y búsqueda semántica
- Function calling (tool use)
- Conversation history management
- Best practices (costos, prompt templates, rate limiting)

**Cuándo se carga**: Detecta `pyproject.toml` con dependencia `openai`

---

### DevOps

#### **bash-scripts.md**
```
Shell: Bash 4.x+
Modo: Strict (set -euo pipefail)
```

**Contenido**:
- Template estándar con strict mode
- Logging con colores
- Error handling y cleanup automático
- Retry con exponential backoff
- Parsing de argumentos con getopts
- Validación de argumentos
- Manejo de archivos y directorios
- Funciones reutilizables
- Ejemplo completo de deploy script

**Cuándo se carga**: Detecta archivos `*.sh` en root del proyecto

---

## 🔧 Personalización

### Modificar un Skill Existente

```bash
# Edita el skill en el repositorio
vim ~/.claude/skills/python.md

# Los cambios se ven inmediatamente (por symlinks)
# Puedes commitearlos si quieres versionarlos
cd ~/projects/claude-code-auto-skills
git add skills/python.md
git commit -m "feat: add asyncio examples to python skill"
```

### Crear un Skill Nuevo

1. Crea el archivo:
   ```bash
   vim ~/.claude/skills/mi-nuevo-skill.md
   ```

2. Usa esta estructura:
   ```markdown
   # [Nombre] - [Descripción]

   > **Stack**: [Info técnica]
   > **Última actualización**: YYYY-MM-DD

   ## Contenido principal...

   ---

   ## 🔧 Mantenimiento de este Skill
   [Instrucciones para Claude Code]
   ```

3. Añade detección automática en `CLAUDE.md`:
   ```markdown
   **a) Detecta automáticamente**:
   mi-archivo.config → mi-nuevo-skill.md
   ```

Ver [CUSTOMIZATION.md](../CUSTOMIZATION.md) para guía completa.

---

## 📊 Estadísticas

- **Total de skills**: 6
- **Líneas de código de ejemplo**: ~2000+
- **Tamaño total**: ~40KB
- **Lenguajes cubiertos**: PHP, Python, TypeScript, Bash
- **Frameworks**: Symfony, Playwright
- **APIs**: OpenAI

---

## 🤝 Contributing

¿Quieres añadir un skill nuevo o mejorar uno existente?

Ver [CONTRIBUTING.md](../CONTRIBUTING.md) para:
- Cómo proponer nuevos skills
- Guía de estilo
- Proceso de review
- Checklist para nuevo skill

**Skills deseados por la comunidad**:
- Laravel
- Django
- NestJS
- Go
- Rust
- Vue
- React
- Docker
- Kubernetes

---

## 📖 Recursos

- [Documentación principal](../README.md)
- [Guía de personalización](../docs/CUSTOMIZATION.md)
- [Cómo contribuir](../docs/CONTRIBUTING.md)

---

*Última actualización: 2026-02-04*
