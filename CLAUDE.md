# Perfil de Desarrollo - jgmoreu

## Stack Tecnológico

### Backend (Expertise Principal)
- **Senior Backend Developer**: PHP/Symfony (8+ años)
- **Arquitectura**: Hexagonal (Ports & Adapters)
- **ORM**: Doctrine
- **Testing**: PHPUnit + Behat
- **Quality**: PHPStan level 9

### Testing E2E (Tech Lead)
- **Framework**: Playwright + TypeScript
- **Patrón**: Page Object Model (POM) estricto
- **Experiencia**: Liderazgo técnico en testing E2E

### En Aprendizaje
- **Python**: Para proyectos LLMs/IA
- **OpenAI API**: Integración y desarrollo de aplicaciones IA
- **Transition**: Aplicando experiencia PHP a Python

### Herramientas
- **MCPs activos**: GitHub, Context7
- **Versionado**: Git + GitHub
- **CI/CD**: Automatización con scripts bash

---

## Preferencias de Código

### Principios Generales
- **KISS**: Priorizar simplicidad sobre complejidad
- **Type Safety**: Siempre que el lenguaje lo permita
- **Tests**: Cobertura mínima 80% en lógica crítica
- **DRY**: Evitar duplicación, pero sin abstracciones prematuras
- **Docs**: Solo cuando aporta valor (evitar obviedades)
- **Clean Code**: Código auto-explicativo > comentarios excesivos

### Naming Conventions

#### PHP/Symfony
- Clases: `PascalCase` (ej: `UserRepository`)
- Métodos/funciones: `camelCase` (ej: `findUserById`)
- Propiedades: `camelCase` (ej: `$userName`)
- Constantes: `UPPER_SNAKE_CASE` (ej: `MAX_RETRIES`)
- Interfaces: `PascalCase` + `Interface` (ej: `UserRepositoryInterface`)
- Variables privadas: `camelCase` con typed properties

#### TypeScript
- Interfaces: `PascalCase` sin prefijo I (ej: `User`)
- Types: `PascalCase` (ej: `UserId`)
- Funciones: `camelCase` (ej: `getUserById`)
- Constantes: `UPPER_SNAKE_CASE` (ej: `API_BASE_URL`)
- Archivos: `kebab-case.ts` o `PascalCase.ts` para componentes

#### Python
- Clases: `PascalCase` (ej: `UserService`)
- Funciones/métodos: `snake_case` (ej: `get_user_by_id`)
- Variables: `snake_case` (ej: `user_name`)
- Constantes: `UPPER_SNAKE_CASE` (ej: `MAX_RETRIES`)
- Archivos de test: `test_*.py`
- Private: `_private_method` (convención)

#### Bash
- Scripts: `kebab-case.sh` o `snake_case.sh`
- Funciones: `snake_case` (ej: `deploy_to_production`)
- Variables locales: `snake_case` (ej: `user_name`)
- Constantes: `UPPER_SNAKE_CASE` (ej: `readonly MAX_RETRIES=3`)

### Arquitectura

#### Backend (Symfony)
```
src/
├── Domain/          # Lógica de negocio pura
├── Application/     # Use cases
├── Infrastructure/  # Adaptadores (HTTP, DB, etc.)
└── Shared/          # Código compartido
```

#### Testing E2E (Playwright)
```
tests/
├── pages/    # Page Objects (única fuente de selectores)
├── specs/    # Tests
└── fixtures/ # Datos y configuración
```

#### Python (Proyectos IA)
```
src/
├── domain/          # Lógica de negocio
├── application/     # Casos de uso
├── infrastructure/  # Adaptadores (APIs, DB)
└── config/          # Configuración
```

---

## Skills Especializados

Los siguientes skills están disponibles en `~/.claude/skills/`:

### Backend & Arquitectura
- **php-symfony.md** - Symfony framework, Doctrine ORM, testing
- **laravel.md** - Laravel framework, Eloquent ORM, Blade
- **arquitectura-hexagonal.md** - Ports & Adapters, DDD patterns
- **solid.md** - SOLID principles con ejemplos PHP/Python
- **clean-code.md** - Clean Code practices y refactoring

### Frontend & Templates
- **react.md** - React hooks, TypeScript, modern patterns
- **typescript.md** - Types, generics, strict mode
- **twig.md** - Twig templating (Symfony)
- **volt.md** - Volt templating (Phalcon/Symfony)

### Testing
- **playwright.md** - Playwright E2E testing basics
- **pom.md** - Page Object Model pattern (deep dive)
- **cucumber.md** - BDD con Gherkin y Playwright

### Quality & Documentation
- **phpstan.md** - Static analysis level 9
- **swagger.md** - OpenAPI/Swagger documentation

### API & Integration
- **openai.md** - OpenAI API patterns con Python

### Languages & Tools
- **python.md** - Guía PHP → Python con equivalencias
- **bash-scripts.md** - Scripts robustos con logging y error handling

---

## 🚀 Sistema de Auto-Carga de Skills (Opción D)

### Para Claude Code:

#### Primera Interacción en Proyecto Nuevo

Cuando trabajes en un proyecto por primera vez:

**1. Verifica si existe MEMORY.md**:
```bash
if [ -f "$(pwd)/MEMORY.md" ]; then
  # Cargar skills listados automáticamente
else
  # Proceso de auto-configuración
fi
```

**2. Si NO existe MEMORY.md**:

**a) Detecta automáticamente**:
```bash
# Backend Frameworks
composer.json + symfony/ → php-symfony.md, arquitectura-hexagonal.md, twig.md
composer.json + laravel/ → laravel.md
pyproject.toml           → python.md
requirements.txt         → python.md

# Frontend
package.json + tsconfig.json → typescript.md
package.json + react        → react.md
tsconfig.json               → typescript.md

# Testing
playwright.config.ts → playwright.md, pom.md
package.json + @cucumber/cucumber → cucumber.md

# Templates
artisan (Laravel)    → laravel.md (Blade)
symfony + twig/      → twig.md
phalcon/             → volt.md

# Tools & Scripts
*.sh en root         → bash-scripts.md
phpstan.neon         → phpstan.md
```

**Verificación adicional**:
- Si `pyproject.toml` contiene `openai` → añadir `openai.md`
- Si `package.json` contiene `@playwright/test` → añadir `playwright.md`, `pom.md`
- Si `package.json` contiene `@cucumber/cucumber` → añadir `cucumber.md`
- Si `composer.json` contiene `nelmio/api-doc-bundle` → añadir `swagger.md`
- Si `phpstan.neon` existe → añadir `phpstan.md`
- Si proyecto usa React → sugerir `solid.md`, `clean-code.md`

**b) Pregunta al usuario**:
```
🔍 Analizando proyecto...

📂 Detectado:
✓ composer.json (Symfony project)
✓ package.json + tsconfig.json (TypeScript)
✓ deploy.sh (bash scripts)

📚 Skills disponibles:
1. php-symfony.md - Arquitectura hexagonal, Doctrine
2. typescript.md - Types, generics, convenciones
3. bash-scripts.md - Deploy scripts, error handling

¿Cuáles quieres cargar?
(escribe números separados por coma, 'todos', o 'ninguno'):
```

**c) Crea MEMORY.md automáticamente**:
```markdown
# Skills Configurados - [Nombre del Proyecto]

Auto-generado por Claude Code el YYYY-MM-DD

## Skills Activos
- php-symfony.md
- typescript.md

## Skills Disponibles (no cargados)
- python.md
- playwright.md
- bash-scripts.md
- openai.md

## Notas del Proyecto
[El usuario puede añadir notas específicas aquí]

---
💡 Para modificar: "carga [skill]" o "remueve [skill]"
*Última actualización: YYYY-MM-DD HH:MM*
```

**d) Carga los skills seleccionados**:
- Lee el contenido de cada skill de `~/.claude/skills/`
- Aplica las convenciones y patterns
- Continúa trabajando con ese contexto

**e) Notifica brevemente**:
```
✅ Skills cargados: php-symfony, typescript
📝 Configuración guardada en MEMORY.md
```

**3. Si SÍ existe MEMORY.md**:

**a) Lee la sección "Skills Activos"** silenciosamente

**b) Carga automáticamente** sin preguntar

**c) Notifica brevemente** (1 línea):
```
📚 Skills cargados: php-symfony, typescript
```

**d) Continúa trabajando** con el contexto cargado

#### Durante la Sesión

**Añadir skill dinámicamente**:

Usuario dice: `"carga también python.md"` o `"necesito usar OpenAI"`

```
📚 Cargando skill adicional: python.md

¿Actualizar MEMORY.md para cargarlo automáticamente en próximas sesiones? (s/n)
```

Si responde "sí":
```
✅ python.md cargado
💾 MEMORY.md actualizado
```

Si responde "no":
```
✅ python.md cargado (solo para esta sesión)
```

**Remover skill**:

Usuario dice: `"ya no necesito typescript.md"` o `"remueve typescript"`

```
✅ Removido typescript.md de la sesión actual
💾 MEMORY.md actualizado

Skills activos ahora:
- php-symfony.md
```

**Listar skills**:

Usuario dice: `"qué skills están cargados"` o `"/skills"` o `"lista skills"`

```
📚 Skills Activos:
✓ php-symfony.md
✓ typescript.md

📦 Skills Disponibles:
○ python.md
○ playwright.md
○ bash-scripts.md
○ openai.md

💡 Comandos:
- "carga [skill]" para añadir
- "remueve [skill]" para quitar
```

#### Formato Estándar de MEMORY.md

```markdown
# Skills Configurados - [Nombre del Proyecto]

Auto-generado por Claude Code el YYYY-MM-DD

## Skills Activos
- php-symfony.md
- typescript.md
- bash-scripts.md

## Skills Disponibles (no cargados)
- python.md
- playwright.md
- openai.md

## Notas del Proyecto
Aquí el usuario puede añadir:
- Información específica del proyecto
- Decisiones de arquitectura
- Comandos útiles frecuentes
- Contexto del negocio

Ejemplo:
- Base de datos: PostgreSQL 16
- Cache: Redis
- Queue: RabbitMQ
- Deploy: AWS ECS

## Comandos Útiles
\`\`\`bash
make test           # Run all tests
make deploy-staging # Deploy to staging
\`\`\`

---
*Auto-gestionado por Claude Code*
*Última actualización: YYYY-MM-DD HH:MM*
```

---

## 🔧 Meta-Instrucciones de Auto-Mantenimiento

### Para Claude Code:

Eres responsable de mantener los skills actualizados siguiendo estas reglas:

#### Cuándo Actualizar Skills:

**1. Detección automática durante conversación**:
- Nuevas best practices relevantes aparecen
- Cambios en APIs (OpenAI, Playwright, Symfony)
- Patrones que funcionaron bien para el usuario
- Errores comunes que el usuario cometió y fueron resueltos
- Nuevas versiones de librerías/frameworks

**2. Solicitud explícita**:
- Usuario dice "actualiza skills" o similar
- Usuario reporta información desactualizada

#### Cómo Actualizar:

**1. Usa Context7 para documentación actualizada**:
```
# Ejemplos de uso:
mcp__context7__resolve-library-id: libraryName="Symfony"
mcp__context7__query-docs: libraryId="/symfony/symfony", query="new features Symfony 7.2"

mcp__context7__resolve-library-id: libraryName="Playwright"
mcp__context7__query-docs: libraryId="/microsoft/playwright", query="latest Playwright patterns"

mcp__context7__resolve-library-id: libraryName="OpenAI Python"
mcp__context7__query-docs: libraryId="/openai/openai-python", query="openai sdk 1.50 changes"
```

**2. Preserva SIEMPRE**:
- ✅ Preferencias personales del usuario
- ✅ Convenciones de naming definidas
- ✅ Estructura de archivos existente
- ✅ Ejemplos específicos del stack del usuario
- ✅ Sección de auto-mantenimiento de cada skill

**3. Añade sin reemplazar**:
- Nuevas secciones al final del skill
- Ejemplos adicionales
- Actualizaciones de versiones con notas de cambio
- Marca como "Actualizado: YYYY-MM-DD"

**4. Usa Edit, no Write**:
- SIEMPRE usa `Edit` tool para preservar contenido existente
- Lee el skill completo antes de editar
- Identifica la sección específica a actualizar
- Solo modifica lo necesario

**5. Notifica al usuario claramente**:
```
📝 Actualizado ~/.claude/skills/openai.md:

Cambios:
+ Añadida sección: Batch API (nueva en SDK 1.50.0)
+ Actualizado modelo recomendado: gpt-4o → gpt-4o-2026-02
+ Ejemplo de streaming mejorado con error handling

Preservado:
✓ Tus patrones de retry/backoff
✓ Ejemplos con type hints
✓ Convenciones de naming
```

#### Proceso de Actualización Paso a Paso:

1. **Detecta necesidad de actualización**
2. **Lee el skill actual** con `Read` tool
3. **Consulta Context7** si es necesario para info actualizada
4. **Identifica sección específica** a actualizar
5. **Usa Edit tool** para modificar solo esa sección
6. **Notifica al usuario** qué se actualizó y qué se preservó

#### Ejemplo de Prompt Interno para Actualización:

```
He detectado que estás usando OpenAI SDK 1.50.0 pero el skill
openai.md tiene ejemplos de 1.30.0.

Voy a:
1. Leer ~/.claude/skills/openai.md
2. Consultar Context7 para cambios en SDK 1.50.0
3. Actualizar ejemplos de API calls
4. Preservar tus patrones de error handling
5. Añadir nuevas features (Batch API) al final

¿Procedo con la actualización?
```

### Regla de Oro:

**NUNCA reemplaces preferencias personales por "best practices" genéricas.**

```
Preferencias del usuario > Convenciones de la comunidad
```

Si hay conflicto entre una best practice nueva y una preferencia establecida del usuario, **pregunta primero**:

```
💡 Nueva best practice detectada:

TypeScript ahora recomienda usar `satisfies` en lugar de `as const`.

Tu skill actual usa `as const` consistentemente.

¿Quieres que actualice el skill con el nuevo patrón `satisfies`? (s/n)
```

---

## 🎯 Comandos Rápidos

Estos son atajos que puedes usar:

- `"lista skills"` o `"/skills"` → Muestra skills activos y disponibles
- `"carga [skill]"` → Carga un skill adicional
- `"remueve [skill]"` → Remueve skill de la sesión
- `"actualiza skills"` → Revisa y actualiza skills si es necesario
- `"crea MEMORY.md"` → Crea configuración para el proyecto actual

---

## 📊 Prioridad de Configuración

Cuando hay múltiples fuentes de configuración:

```
1. MEMORY.md del proyecto actual (máxima prioridad)
   ↓
2. Skills específicos de ~/.claude/skills/
   ↓
3. CLAUDE.md global (este archivo)
   ↓
4. Defaults de Claude Code
```

Si hay conflicto, siempre gana la configuración más específica (arriba en la lista).

---

## 🤝 Filosofía de Trabajo

- **Pragmatismo sobre purismo**: Si funciona bien y es simple, es mejor
- **Evolución incremental**: Mejora continua sin grandes refactors
- **Testing como documentación**: Los tests deben explicar el comportamiento
- **Code review mental**: Siempre preguntarse "¿alguien más entenderá esto en 6 meses?"

---

*Este archivo es gestionado manualmente. Los skills en `~/.claude/skills/` se auto-actualizan.*
*Última actualización: 2026-02-04*
