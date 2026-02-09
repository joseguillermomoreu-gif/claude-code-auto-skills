# Contributing to claude-code-auto-skills

¡Gracias por tu interés en contribuir! 🎉

---

## 📖 Documentación Importante

Antes de contribuir, lee la documentación completa del workflow:

👉 **[docs/WORKFLOW.md](docs/WORKFLOW.md)** - Gitflow, convenciones, TDD, CI/CD

Esta es la guía definitiva que cubre:
- Gitflow completo (master, develop, feature, hotfix, release)
- Branch naming conventions (`feature/t_XX_descripcion`)
- Conventional commits
- TDD para scripts bash
- Proceso de release

---

## 🚀 Quick Start para Contributors

### 1. Fork y Clone

```bash
# Fork en GitHub primero, luego:
git clone https://github.com/TU-USUARIO/claude-code-auto-skills.git
cd claude-code-auto-skills
```

### 2. Setup de Desarrollo

```bash
# Instalar dependencias para testing
npm install -g bats

# Instalar shellcheck (linter)
# Ubuntu/Debian:
sudo apt-get install shellcheck

# macOS:
brew install shellcheck
```

### 3. Workflow Básico

```bash
# 1. Actualizar develop
git checkout develop
git pull upstream develop

# 2. Crear branch siguiendo convención
git checkout -b feature/t_06_add_django_skill

# 3. Hacer cambios
# ... editar archivos ...

# 4. Si modificas .sh → TDD obligatorio
./tests/run_tests.sh

# 5. Commit con conventional commits
git commit -m "feat: add django.md skill"

# 6. Push y crear PR
git push origin feature/t_06_add_django_skill
gh pr create --base develop
```

---

## 🎯 Tipos de Contribuciones

### 1. Nuevos Skills

**Issues existentes**: Ver [lista de skills pendientes](https://github.com/joseguillermomoreu-gif/claude-code-auto-skills/issues?q=is%3Aissue+is%3Aopen+label%3A%22type%3A+skill%22)

**Proceso**:
1. Comentar en el issue que quieres trabajar en él
2. Crear branch: `feature/t_XX_add_SKILL_skill`
3. Crear `skills/SKILL.md` siguiendo estructura de skills existentes
4. Actualizar `README.md` con el nuevo skill
5. Commit: `feat: add SKILL.md skill`
6. PR a `develop`

**Estructura mínima de un skill**:

```markdown
# Skill Name - Descripción Corta

> **Stack**: Tecnología X.Y.Z
> **Última actualización**: YYYY-MM-DD

## Sección 1

Contenido...

## Sección 2

Contenido...

## Naming Conventions

```bash
# Ejemplos...
```

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- Cambios relevantes...

**Preserva siempre**:
- Preferencias del usuario...
```

### 2. Mejoras a Scripts (.sh)

**⚠️ TDD OBLIGATORIO**

Ver: [docs/WORKFLOW.md#tdd-para-scripts-bash](docs/WORKFLOW.md#tdd-para-scripts-bash)

**Proceso**:
1. Crear branch: `feature/t_XX_descripcion`
2. **RED**: Escribir test que falla
   ```bash
   vim tests/test_install.sh
   @test "descripción" { ... }
   ./tests/run_tests.sh  # ❌ FAIL
   ```
3. **GREEN**: Implementar feature
   ```bash
   vim install.sh
   ./tests/run_tests.sh  # ✅ PASS
   ```
4. **REFACTOR**: Mejorar código
5. Commit: `feat: descripción del cambio`
6. PR a `develop`

### 3. Documentación

**Proceso**:
1. Crear branch: `docs/t_XX_descripcion`
2. Editar documentación
3. Commit: `docs: descripción del cambio`
4. PR a `develop`

### 4. Bug Fixes

**Hotfixes urgentes** (desde `master`):
```bash
git checkout master
git checkout -b hotfix/t_XX_descripcion
# ... fix ...
git commit -m "fix: descripción"
# PR a master
```

**Bugs normales** (desde `develop`):
```bash
git checkout develop
git checkout -b bugfix/t_XX_description
# ... fix ...
git commit -m "fix: descripción"
# PR a develop
```

---

## 📋 Convenciones

### Branch Naming

**Formato obligatorio**: `{tipo}/t_{numero}_{descripcion}`

```bash
feature/t_06_add_django_skill
hotfix/t_42_fix_install_bug
docs/t_05_update_workflow
```

### Conventional Commits

```bash
feat: nueva feature (minor bump)
fix: bug fix (patch bump)
docs: solo documentación (no bump)
test: añadir/modificar tests (no bump)
chore: tareas de mantenimiento (no bump)
refactor: refactorización (no bump)

# Breaking change (major bump)
feat!: breaking change
fix!: breaking fix
```

**Ejemplos**:

```bash
# ✅ BIEN
feat: add django.md skill
fix: install.sh creates backup correctly
docs: add ARCHITECTURE.md
test: add tests for update.sh

# ❌ MAL
added django skill
Fixed bug
Update docs
```

### Testing

**Si modificas `.sh` → TDD obligatorio**

```bash
# Ejecutar tests localmente
./tests/run_tests.sh

# Test específico
./tests/run_tests.sh test_install.sh

# Ver: tests/README.md para más info
```

---

## ✅ Checklist antes de PR

- [ ] Branch sigue convención: `feature/t_XX_descripcion`
- [ ] Si modifiqué `.sh`: tests añadidos/actualizados
- [ ] Tests pasan localmente: `./tests/run_tests.sh`
- [ ] ShellCheck sin warnings: `shellcheck *.sh`
- [ ] Commits siguen conventional commits
- [ ] Documentación actualizada si es necesario
- [ ] PR tiene título descriptivo
- [ ] PR referencia issue: "Closes #XX"

---

## 🤝 Code Review

### Para Contributors

- ✅ PRs serán revisados en 1-3 días
- ✅ Feedback constructivo y específico
- ✅ Cambios solicitados son obligatorios antes de merge
- ✅ Si pasan tests + review → merge automático

### Para Reviewers

- ✅ Verificar tests pasan
- ✅ Verificar conventional commits
- ✅ Verificar código sigue convenciones
- ✅ Probar cambios localmente si es .sh
- ✅ Feedback específico y constructivo

---

## 🏷️ Labels de Issues

| Label | Descripción |
|-------|-------------|
| `priority: P0` | Crítico - resolver inmediatamente |
| `priority: P1` | Importante - próxima iteración |
| `priority: P2` | Medio - backlog |
| `priority: P3` | Bajo - futuro |
| `type: skill` | Nuevo skill o actualización |
| `type: documentation` | Mejora de documentación |
| `type: testing` | Testing related |
| `type: enhancement` | Mejora de feature existente |
| `refinement-needed` | Requiere refinamiento antes de implementar |

---

## 📞 Preguntas

**¿Tienes dudas?**

1. Revisa [docs/WORKFLOW.md](docs/WORKFLOW.md)
2. Revisa [tests/README.md](tests/README.md) si es sobre testing
3. Busca en [issues existentes](https://github.com/joseguillermomoreu-gif/claude-code-auto-skills/issues)
4. Crea issue con label `question`

---

## 🎉 Reconocimientos

Los contributors aparecerán en:
- README.md (sección Contributors)
- Release notes
- Agradecimientos en redes sociales

---

**¡Gracias por contribuir!** 🚀

Desarrollado con 💙 por [José Guillermo Moreu](https://github.com/joseguillermomoreu-gif)
