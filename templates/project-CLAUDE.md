# [Nombre del Proyecto]

> Template para CLAUDE.md específico de proyecto.
> Copia este archivo al root de tu proyecto y personalízalo.

## Contexto del Proyecto

**Descripción**: [Describe brevemente qué hace este proyecto]

**Tipo**: [Backend API / Frontend SPA / Microservicio / CLI Tool / etc.]

**Estado**: [En desarrollo / Producción / Mantenimiento]

---

## Skills Activos

> Estos skills se cargan automáticamente desde ~/.claude/skills/
> Si no existe MEMORY.md, esta sección indica tus preferencias

**Para este proyecto, usar**:
- ✅ php-symfony.md - Backend con Symfony
- ✅ typescript.md - Frontend con React
- ✅ bash-scripts.md - Scripts de deploy
- ❌ python.md - No aplica en este proyecto
- ❌ playwright.md - No tenemos E2E aquí (solo unit tests)
- ❌ openai.md - No usa IA

---

## Stack Técnico

### Backend
- Framework: Symfony 7.2
- PHP: 8.3
- Database: PostgreSQL 16
- ORM: Doctrine
- Testing: PHPUnit + Behat

### Frontend
- Framework: React 18
- Language: TypeScript 5.x
- State: Redux Toolkit
- Testing: Vitest + Testing Library

### Infraestructura
- Server: AWS ECS
- Cache: Redis
- Queue: RabbitMQ
- Storage: S3
- CI/CD: GitHub Actions

---

## Arquitectura

### Backend (Hexagonal)

```
src/
├── Domain/              # Lógica de negocio pura
│   ├── Entity/         # Entities
│   ├── ValueObject/    # Value Objects
│   ├── Repository/     # Repository interfaces
│   └── Service/        # Domain services
│
├── Application/         # Use cases
│   ├── UseCase/        # Command/Query handlers
│   └── DTO/            # Data Transfer Objects
│
├── Infrastructure/      # Adaptadores
│   ├── Persistence/    # Doctrine repositories
│   ├── Controller/     # HTTP controllers
│   ├── Command/        # CLI commands
│   └── EventListener/  # Event subscribers
│
└── Shared/             # Código compartido
    └── Kernel.php
```

### Frontend

```
src/
├── features/           # Features (slices)
│   ├── auth/
│   ├── products/
│   └── orders/
├── components/         # Shared components
├── hooks/              # Custom hooks
├── store/              # Redux store
└── utils/              # Utilities
```

---

## Convenciones Específicas del Proyecto

### Naming

**Backend**:
- Commands: `CreateOrderCommand`, `UpdateUserCommand`
- Handlers: `CreateOrderHandler`, `UpdateUserHandler`
- Events: `OrderCreatedEvent`, `UserUpdatedEvent`
- Exceptions: `OrderNotFoundException`, `InvalidEmailException`

**Frontend**:
- Components: `PascalCase` (ej: `ProductCard.tsx`)
- Hooks: `use` prefix (ej: `useAuth.ts`)
- Utils: `camelCase` (ej: `formatCurrency.ts`)
- Types: `PascalCase` (ej: `User.ts`)

### Git

**Branches**:
```
feature/TICKET-123-add-user-authentication
bugfix/TICKET-456-fix-payment-validation
hotfix/critical-security-patch
```

**Commits**:
```
feat: add user authentication endpoint
fix: correct payment validation logic
refactor: extract order processing to service
test: add unit tests for UserService
docs: update API documentation
```

---

## Comandos Útiles

### Development

```bash
# Backend
make dev                    # Start dev environment (docker-compose up)
make test                   # PHPUnit + Behat
make phpstan                # Static analysis level 9
make cs-fix                 # PHP-CS-Fixer

# Frontend
npm run dev                 # Vite dev server
npm run test                # Vitest
npm run lint                # ESLint
npm run type-check          # TypeScript check
```

### Database

```bash
make db-reset               # Drop + create + migrate + fixtures
make db-migrate             # Run pending migrations
make db-rollback            # Rollback last migration
make db-fixtures            # Load fixtures
```

### Deployment

```bash
make deploy-staging         # Deploy to staging
make deploy-prod            # Deploy to production (requires approval)
make rollback               # Rollback to previous version
```

### Quality

```bash
make coverage               # Generate coverage report (min 80%)
make ci                     # Run all CI checks locally
```

---

## Testing

### Coverage Mínima
- **Domain**: 100% (lógica crítica)
- **Application**: 90% (use cases)
- **Infrastructure**: 70% (adaptadores)
- **Total**: 80% mínimo

### Estrategia
- **Unit tests**: Domain + Application (sin infraestructura)
- **Integration tests**: Repositories, APIs externas
- **E2E tests**: Flujos críticos con Behat

---

## Decisiones de Arquitectura

### ¿Por qué Hexagonal?
- Facilita testing independiente de infraestructura
- Permite cambiar implementaciones sin afectar lógica de negocio
- Clara separación de responsabilidades

### ¿Por qué Doctrine Custom Types para Value Objects?
- Transparencia: El dominio no conoce detalles de persistencia
- Type safety en queries
- Reutilización de validaciones

### ¿Por qué Redux en frontend?
- Estado complejo con múltiples fuentes
- DevTools para debugging
- Middleware para side effects (API calls)

---

## APIs Externas

### Stripe (Pagos)
- API Key en `.env`: `STRIPE_API_KEY`
- Webhook: `/webhook/stripe`
- Docs: https://stripe.com/docs/api

### SendGrid (Emails)
- API Key en `.env`: `SENDGRID_API_KEY`
- Templates en dashboard de SendGrid
- Docs: https://docs.sendgrid.com

---

## Variables de Entorno

### Requeridas (.env)

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# Redis
REDIS_URL=redis://localhost:6379

# RabbitMQ
RABBITMQ_URL=amqp://guest:guest@localhost:5672

# APIs externas
STRIPE_API_KEY=sk_test_...
SENDGRID_API_KEY=SG....

# AWS
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_S3_BUCKET=my-bucket
```

---

## Troubleshooting

### Error: "Connection refused to database"
```bash
make db-start    # Asegúrate que Docker está corriendo
```

### Error: "Class not found after composer install"
```bash
composer dump-autoload
make cache-clear
```

### Tests fallan con "Database not found"
```bash
make test-db-setup    # Crea DB de test
```

---

## Recursos

- **Documentación API**: https://api-docs.example.com
- **Figma Designs**: https://figma.com/...
- **Jira Board**: https://jira.example.com/...
- **Slack Channel**: #proyecto-nombre

---

## Equipo

- **Tech Lead**: José Guillermo Moreu (@joseguillermomoreu-gif)
- **Backend**: [Nombres]
- **Frontend**: [Nombres]
- **QA**: [Nombres]

---

💡 **Tip**: Si Claude Code pregunta qué skills cargar, di "todos" para cargar php-symfony, typescript y bash-scripts automáticamente.

*Última actualización: 2026-02-04*
