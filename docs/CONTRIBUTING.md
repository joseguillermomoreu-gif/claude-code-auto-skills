# Contributing to Claude Code Auto-Skills

¡Gracias por tu interés en contribuir! Este proyecto mejora con la experiencia de la comunidad.

## 🎯 Formas de Contribuir

### 1. 🐛 Reportar Bugs o Información Desactualizada

Si encuentras:
- Información incorrecta o desactualizada en algún skill
- Bugs en el sistema de auto-detección
- Errores en la documentación

**Abre un issue** con:
- Título descriptivo
- Skill afectado (si aplica)
- Qué está mal
- Qué debería ser
- Versión de la librería/framework actual

**Ejemplo**:
```
Título: [php-symfony.md] Sintaxis de atributos desactualizada

Skill: php-symfony.md
Problema: Usa anotaciones de Doctrine (#[ORM\Entity]) pero el skill muestra annotations (@ORM\Entity)
Solución: Actualizar a PHP 8 attributes
Versión: Symfony 7.2, PHP 8.3
```

---

### 2. ✨ Proponer Nuevos Skills

¿Trabajas con un stack que no está cubierto? ¡Compártelo!

**Skills deseados**:
- Backend: Go, Rust, Java/Spring, C#/.NET, Laravel, Django, NestJS
- Frontend: Vue, Svelte, Angular, Next.js, Nuxt
- Mobile: React Native, Flutter, Swift, Kotlin
- Infra: Docker, Kubernetes, Terraform, Ansible
- Databases: PostgreSQL, MySQL, MongoDB, Redis

**Cómo proponer**:

1. Abre un issue con el template:
```markdown
## Nuevo Skill: [Nombre]

**Stack**: [Go, Laravel, etc.]

**¿Por qué es útil?**
[Explica el caso de uso]

**Contenido propuesto**:
- Sección 1: ...
- Sección 2: ...
- Sección 3: ...

**¿Tienes experiencia con esta tecnología?**
[Sí/No - Si sí, podría pedirte ayuda para revisarlo]
```

2. Espera feedback de la comunidad

3. Si hay interés, crea un PR con el skill

---

### 3. 🔧 Mejorar Skills Existentes

Los skills mejoran con el tiempo. Puedes:
- Añadir mejores ejemplos
- Incluir casos de uso adicionales
- Actualizar a nuevas versiones
- Añadir secciones faltantes

**Proceso**:

1. Fork el repositorio

2. Crea una rama:
   ```bash
   git checkout -b improve/php-symfony-add-messenger
   ```

3. Edita el skill en `skills/[nombre].md`

4. **Preserva la estructura**:
   ```markdown
   # Título

   > Metadata del skill

   ## Secciones de contenido...

   ---

   ## 🔧 Mantenimiento de este Skill
   [Esta sección DEBE permanecer al final]
   ```

5. Commit con mensaje descriptivo:
   ```bash
   git commit -m "feat(php-symfony): add Symfony Messenger examples"
   ```

6. Push y abre PR

---

### 4. 📝 Mejorar Documentación

- README.md más claro
- Más ejemplos de uso
- Traducciones (inglés, español, etc.)
- Diagramas y visualizaciones

---

## 🛠️ Guía de Desarrollo

### Estructura del Proyecto

```
claude-code-auto-skills/
├── README.md                    # Documentación principal
├── LICENSE                      # MIT License
├── install.sh                   # Script de instalación
├── CLAUDE.md                    # Configuración global
├── skills/                      # Skills disponibles
│   ├── README.md
│   ├── python.md
│   ├── php-symfony.md
│   ├── typescript.md
│   ├── playwright.md
│   ├── openai.md
│   └── bash-scripts.md
├── templates/
│   ├── MEMORY.md.example
│   └── project-CLAUDE.md
└── docs/
    ├── CONTRIBUTING.md          # Este archivo
    ├── CUSTOMIZATION.md
    └── ARCHITECTURE.md
```

---

## 📋 Estructura de un Skill

Cada skill debe seguir esta estructura:

```markdown
# [Nombre del Skill] - [Descripción Breve]

> **Stack/Versión**: [Info técnica]
> **Última actualización**: YYYY-MM-DD

## Sección 1: Concepto Principal

[Explicación clara con ejemplos]

```language
// Código de ejemplo
function example() {
  // ...
}
```

## Sección 2: Patterns Comunes

### Subsección 2.1

[Contenido]

### Subsección 2.2

[Contenido]

## Sección 3: Best Practices

[Lista de buenas prácticas]

## Comandos Útiles

```bash
# Comandos frecuentes
comando1    # Descripción
comando2    # Descripción
```

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- [Condiciones para actualizar]

**Preserva siempre**:
- [Qué no debe cambiar]

**Usa Context7**:
```language
resolve-library-id: "[librería]"
query-docs: "[query example]"
```
```

---

## ✅ Checklist para Nuevo Skill

Antes de enviar un PR con un nuevo skill, verifica:

- [ ] El skill sigue la estructura estándar
- [ ] Incluye ejemplos de código reales y funcionales
- [ ] Tiene sección de "Mantenimiento de este Skill"
- [ ] Naming conventions están claramente definidas
- [ ] Best practices están justificadas (el "por qué")
- [ ] Comandos útiles están incluidos
- [ ] No tiene errores de sintaxis en código de ejemplo
- [ ] Está escrito en español (o inglés para repo internacional)
- [ ] El archivo tiene ~5-8KB de contenido útil
- [ ] Añadido a `skills/README.md` en la lista

---

## 🎨 Guía de Estilo

### Para Skills (Markdown)

**DO**:
```markdown
✅ Títulos claros con emojis moderados
✅ Código con syntax highlighting
✅ Ejemplos reales y funcionales
✅ Explicaciones concisas
✅ Tablas para comparaciones
```

**DON'T**:
```markdown
❌ Emojis excesivos 🎉✨🔥💯
❌ Código sin contexto
❌ "Lorem ipsum" o placeholders
❌ Párrafos largos sin estructura
❌ Explicaciones obvias
```

### Para Código de Ejemplo

**DO**:
```typescript
// ✅ BIEN: Código completo y funcional
interface User {
  id: string;
  email: string;
  createdAt: Date;
}

function findUser(id: string): User | null {
  // Implementación real
  return users.find(u => u.id === id) ?? null;
}
```

**DON'T**:
```typescript
// ❌ MAL: Código incompleto o con placeholders
interface User {
  // ... propiedades
}

function findUser(id) {
  // TODO: implementar
}
```

---

## 🔍 Proceso de Review

Cuando abres un PR:

1. **Auto-check**: GitHub Actions verifica formato
2. **Review inicial** (1-2 días): Mantenedor revisa estructura
3. **Feedback**: Comentarios o aprobación
4. **Iteración**: Ajustes si es necesario
5. **Merge**: Una vez aprobado

### Criterios de Aprobación

- ✅ Sigue la estructura estándar
- ✅ Contenido técnicamente correcto
- ✅ Ejemplos funcionales
- ✅ Útil para la comunidad
- ✅ No duplica contenido existente

---

## 💬 Comunicación

### Issues

- **Bugs**: `[BUG] Título descriptivo`
- **Features**: `[FEATURE] Título descriptivo`
- **Skills**: `[SKILL] Nombre del skill`
- **Docs**: `[DOCS] Mejora en documentación`

### Pull Requests

Título siguiendo [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(skill-name): add new section about X
fix(php-symfony): correct Doctrine example
docs(readme): improve installation steps
chore: update dependencies
```

Descripción del PR:

```markdown
## Cambios
- [ ] Añadido X
- [ ] Actualizado Y
- [ ] Corregido Z

## Testing
- Probado en [entorno/proyecto]
- Verificado que no rompe [funcionalidad]

## Screenshots (si aplica)
[Imágenes]
```

---

## 🏆 Reconocimientos

Los contribuidores serán reconocidos en:
- README.md (sección de créditos)
- Release notes
- CHANGELOG.md

### Tipos de Contribución

- 🌟 **Core Contributor**: 5+ PRs aprobados
- 📚 **Skill Creator**: Nuevo skill completo
- 🐛 **Bug Hunter**: 3+ bugs reportados/corregidos
- 📖 **Docs Guru**: Mejoras significativas en docs

---

## 📜 Código de Conducta

### Nuestros Estándares

**Esperamos**:
- Respeto mutuo
- Feedback constructivo
- Colaboración positiva
- Aceptar críticas con profesionalismo

**No toleramos**:
- Lenguaje ofensivo o discriminatorio
- Ataques personales
- Spam o autopromoción excesiva
- Comportamiento no profesional

---

## ❓ FAQ para Contributors

### ¿Necesito experiencia previa contribuyendo a open source?

No. Este es un buen proyecto para empezar. Los PRs simples (typos, mejoras en docs) son bienvenidos.

### ¿Cuánto tarda la review de un PR?

Generalmente 1-3 días para feedback inicial. Skills nuevos pueden tomar más tiempo.

### ¿Puedo proponer cambios grandes en la arquitectura?

Sí, pero abre primero un issue para discutir antes de invertir tiempo en el PR.

### ¿Los skills deben estar en español o inglés?

Actualmente en español. Si hay interés, podemos hacer versión i18n.

### ¿Qué pasa si mi skill es muy específico (niche)?

¡Está bien! Skills específicos son valiosos. Ejemplo: "GraphQL con Apollo + TypeScript".

---

## 🙏 Gracias

Tu contribución, sin importar el tamaño, hace este proyecto mejor para todos.

**¿Dudas?** Abre un issue o contacta a [@joseguillermomoreu-gif](https://github.com/joseguillermomoreu-gif)

---

*Última actualización: 2026-02-04*
