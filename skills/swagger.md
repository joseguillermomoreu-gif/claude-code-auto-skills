# Swagger / OpenAPI - API Documentation

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Context7 enabled

---

## Introducción

Swagger (ahora OpenAPI) es una especificación para documentar APIs REST. Permite describir endpoints, parámetros, responses, autenticación y más de forma estandarizada.

**Beneficios:**
- Documentación interactiva auto-generada
- Client SDKs generados automáticamente
- Testing de API desde el browser
- Validación de requests/responses
- Contract-first development

---

## OpenAPI Specification

### Versiones

- **OpenAPI 2.0** (Swagger)
- **OpenAPI 3.0** (actual, recomendada)
- **OpenAPI 3.1** (última, compatible con JSON Schema)

---

## Symfony + NelmioApiDocBundle

### Instalación

```bash
composer require nelmio/api-doc-bundle
```

**config/packages/nelmio_api_doc.yaml:**
```yaml
nelmio_api_doc:
    documentation:
        info:
            title: My API
            description: API Documentation
            version: 1.0.0

        servers:
            - url: https://api.example.com
              description: Production
            - url: https://staging.api.example.com
              description: Staging

        components:
            securitySchemes:
                Bearer:
                    type: http
                    scheme: bearer
                    bearerFormat: JWT

    areas:
        path_patterns:
            - ^/api(?!/doc$)
        host_patterns:
            - ^api\.

    routes:
        path: /api/doc.json
```

---

## Anotaciones vs Atributos PHP 8

### Usando Atributos (Recomendado PHP 8+)

```php
use OpenApi\Attributes as OA;
use Nelmio\ApiDocBundle\Annotation\Model;
use Nelmio\ApiDocBundle\Annotation\Security;

#[OA\Post(
    path: '/api/users',
    summary: 'Create a new user',
    requestBody: new OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            ref: new Model(type: CreateUserDto::class)
        )
    ),
    tags: ['Users'],
    responses: [
        new OA\Response(
            response: 201,
            description: 'User created successfully',
            content: new OA\JsonContent(
                ref: new Model(type: User::class, groups: ['user:read'])
            )
        ),
        new OA\Response(
            response: 400,
            description: 'Validation failed'
        ),
        new OA\Response(
            response: 401,
            description: 'Unauthorized'
        )
    ]
)]
#[Security(name: 'Bearer')]
public function create(
    #[OA\RequestBody] CreateUserDto $dto,
    UserService $service
): JsonResponse {
    $user = $service->create($dto);
    return $this->json($user, 201, [], ['groups' => ['user:read']]);
}
```

### Usando Annotations (PHP 7.4+)

```php
use OpenApi\Annotations as OA;

/**
 * @OA\Post(
 *     path="/api/users",
 *     summary="Create a new user",
 *     tags={"Users"},
 *     @OA\RequestBody(
 *         required=true,
 *         @OA\JsonContent(ref=@Model(type=CreateUserDto::class))
 *     ),
 *     @OA\Response(
 *         response=201,
 *         description="User created",
 *         @OA\JsonContent(ref=@Model(type=User::class, groups={"user:read"}))
 *     )
 * )
 * @Security(name="Bearer")
 */
public function create(CreateUserDto $dto): JsonResponse
{
    // ...
}
```

---

## DTOs y Models

### DTO con Documentación

```php
use OpenApi\Attributes as OA;
use Symfony\Component\Validator\Constraints as Assert;

#[OA\Schema(
    schema: 'CreateUserDto',
    required: ['email', 'password', 'name'],
    type: 'object'
)]
class CreateUserDto
{
    #[OA\Property(
        description: 'User email address',
        example: 'john@example.com'
    )]
    #[Assert\NotBlank]
    #[Assert\Email]
    public string $email;

    #[OA\Property(
        description: 'User password',
        minLength: 8,
        example: 'SecurePassword123!'
    )]
    #[Assert\NotBlank]
    #[Assert\Length(min: 8)]
    public string $password;

    #[OA\Property(
        description: 'User full name',
        example: 'John Doe'
    )]
    #[Assert\NotBlank]
    public string $name;

    #[OA\Property(
        description: 'User role',
        enum: ['ROLE_USER', 'ROLE_ADMIN'],
        example: 'ROLE_USER'
    )]
    public ?string $role = 'ROLE_USER';
}
```

### Entity con Groups

```php
use OpenApi\Attributes as OA;
use Symfony\Component\Serializer\Annotation\Groups;

#[OA\Schema(schema: 'User')]
class User
{
    #[OA\Property(example: 1)]
    #[Groups(['user:read', 'user:list'])]
    private int $id;

    #[OA\Property(example: 'john@example.com')]
    #[Groups(['user:read', 'user:list'])]
    private string $email;

    #[OA\Property(example: 'John Doe')]
    #[Groups(['user:read', 'user:list'])]
    private string $name;

    #[Groups(['user:read'])] // Solo en detalle, no en lista
    #[OA\Property(type: 'array', items: new OA\Items(type: 'string'))]
    private array $roles = [];

    #[Groups(['user:read'])]
    #[OA\Property(example: '2024-01-15T10:30:00Z')]
    private \DateTimeImmutable $createdAt;

    // Password NO va en ningún group (nunca se serializa)
    private string $password;
}
```

---

## Tipos de Respuestas

### Success Response

```php
#[OA\Response(
    response: 200,
    description: 'Successful operation',
    content: new OA\JsonContent(
        properties: [
            new OA\Property(
                property: 'status',
                type: 'string',
                example: 'success'
            ),
            new OA\Property(
                property: 'data',
                ref: new Model(type: User::class)
            )
        ]
    )
)]
```

### Paginated Response

```php
#[OA\Response(
    response: 200,
    description: 'Paginated list',
    content: new OA\JsonContent(
        properties: [
            new OA\Property(
                property: 'items',
                type: 'array',
                items: new OA\Items(ref: new Model(type: User::class, groups: ['user:list']))
            ),
            new OA\Property(property: 'total', type: 'integer', example: 100),
            new OA\Property(property: 'page', type: 'integer', example: 1),
            new OA\Property(property: 'perPage', type: 'integer', example: 20)
        ]
    )
)]
```

### Error Response

```php
#[OA\Response(
    response: 422,
    description: 'Validation error',
    content: new OA\JsonContent(
        properties: [
            new OA\Property(property: 'error', type: 'string', example: 'Validation failed'),
            new OA\Property(
                property: 'violations',
                type: 'array',
                items: new OA\Items(
                    properties: [
                        new OA\Property(property: 'field', type: 'string', example: 'email'),
                        new OA\Property(property: 'message', type: 'string', example: 'This value is not a valid email.')
                    ]
                )
            )
        ]
    )
)]
```

---

## Parámetros

### Query Parameters

```php
#[OA\Get(
    path: '/api/users',
    summary: 'List users',
    tags: ['Users'],
    parameters: [
        new OA\Parameter(
            name: 'page',
            in: 'query',
            description: 'Page number',
            required: false,
            schema: new OA\Schema(type: 'integer', default: 1, minimum: 1)
        ),
        new OA\Parameter(
            name: 'limit',
            in: 'query',
            description: 'Items per page',
            required: false,
            schema: new OA\Schema(type: 'integer', default: 20, minimum: 1, maximum: 100)
        ),
        new OA\Parameter(
            name: 'search',
            in: 'query',
            description: 'Search term',
            required: false,
            schema: new OA\Schema(type: 'string', example: 'john')
        ),
        new OA\Parameter(
            name: 'sort',
            in: 'query',
            description: 'Sort field',
            required: false,
            schema: new OA\Schema(type: 'string', enum: ['name', 'email', 'createdAt'], default: 'createdAt')
        )
    ]
)]
public function list(Request $request): JsonResponse
{
    // ...
}
```

### Path Parameters

```php
#[OA\Get(
    path: '/api/users/{id}',
    summary: 'Get user by ID',
    tags: ['Users'],
    parameters: [
        new OA\Parameter(
            name: 'id',
            in: 'path',
            description: 'User ID',
            required: true,
            schema: new OA\Schema(type: 'integer', example: 1)
        )
    ]
)]
public function show(int $id, UserRepository $repo): JsonResponse
{
    // ...
}
```

### Header Parameters

```php
#[OA\Parameter(
    name: 'X-API-Key',
    in: 'header',
    description: 'API Key for authentication',
    required: true,
    schema: new OA\Schema(type: 'string')
)]
```

---

## Security Schemes

### JWT Bearer

```php
// En controller o global
#[Security(name: 'Bearer')]

// En nelmio_api_doc.yaml
components:
    securitySchemes:
        Bearer:
            type: http
            scheme: bearer
            bearerFormat: JWT
            description: 'Enter JWT token'
```

### API Key

```yaml
components:
    securitySchemes:
        ApiKey:
            type: apiKey
            in: header
            name: X-API-Key
```

### OAuth2

```yaml
components:
    securitySchemes:
        OAuth2:
            type: oauth2
            flows:
                authorizationCode:
                    authorizationUrl: https://example.com/oauth/authorize
                    tokenUrl: https://example.com/oauth/token
                    scopes:
                        read: Read access
                        write: Write access
```

---

## Tags y Organización

```php
#[OA\Tag(
    name: 'Users',
    description: 'User management endpoints'
)]
#[OA\Tag(
    name: 'Auth',
    description: 'Authentication endpoints'
)]
class UserController extends AbstractController
{
    #[OA\Post(tags: ['Auth'])]
    public function login() {}

    #[OA\Post(tags: ['Users'])]
    public function create() {}
}
```

---

## Ejemplos Completos

### CRUD Completo

```php
#[OA\Tag(name: 'Products')]
class ProductController
{
    #[OA\Get(
        path: '/api/products',
        summary: 'List all products',
        tags: ['Products'],
        parameters: [
            new OA\Parameter(name: 'page', in: 'query', schema: new OA\Schema(type: 'integer', default: 1)),
            new OA\Parameter(name: 'category', in: 'query', schema: new OA\Schema(type: 'string'))
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Success',
                content: new OA\JsonContent(type: 'array', items: new OA\Items(ref: new Model(type: Product::class)))
            )
        ]
    )]
    public function index() {}

    #[OA\Get(
        path: '/api/products/{id}',
        summary: 'Get product by ID',
        tags: ['Products'],
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        responses: [
            new OA\Response(response: 200, description: 'Success', content: new OA\JsonContent(ref: new Model(type: Product::class))),
            new OA\Response(response: 404, description: 'Not found')
        ]
    )]
    public function show(int $id) {}

    #[OA\Post(
        path: '/api/products',
        summary: 'Create product',
        requestBody: new OA\RequestBody(content: new OA\JsonContent(ref: new Model(type: CreateProductDto::class))),
        tags: ['Products'],
        responses: [
            new OA\Response(response: 201, description: 'Created', content: new OA\JsonContent(ref: new Model(type: Product::class))),
            new OA\Response(response: 400, description: 'Validation error')
        ]
    )]
    #[Security(name: 'Bearer')]
    public function create() {}

    #[OA\Put(
        path: '/api/products/{id}',
        summary: 'Update product',
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        requestBody: new OA\RequestBody(content: new OA\JsonContent(ref: new Model(type: UpdateProductDto::class))),
        tags: ['Products'],
        responses: [
            new OA\Response(response: 200, description: 'Updated', content: new OA\JsonContent(ref: new Model(type: Product::class))),
            new OA\Response(response: 404, description: 'Not found')
        ]
    )]
    #[Security(name: 'Bearer')]
    public function update(int $id) {}

    #[OA\Delete(
        path: '/api/products/{id}',
        summary: 'Delete product',
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        tags: ['Products'],
        responses: [
            new OA\Response(response: 204, description: 'Deleted'),
            new OA\Response(response: 404, description: 'Not found')
        ]
    )]
    #[Security(name: 'Bearer')]
    public function delete(int $id) {}
}
```

---

## File Uploads

```php
#[OA\Post(
    path: '/api/products/{id}/image',
    summary: 'Upload product image',
    requestBody: new OA\RequestBody(
        content: new OA\MediaType(
            mediaType: 'multipart/form-data',
            schema: new OA\Schema(
                required: ['file'],
                properties: [
                    new OA\Property(
                        property: 'file',
                        type: 'string',
                        format: 'binary'
                    )
                ]
            )
        )
    ),
    tags: ['Products'],
    responses: [
        new OA\Response(response: 200, description: 'Uploaded'),
        new OA\Response(response: 400, description: 'Invalid file')
    ]
)]
public function uploadImage(int $id, Request $request): JsonResponse
{
    // ...
}
```

---

## Best Practices

### ✅ DO

```php
// Usa atributos PHP 8 (más limpio)
#[OA\Post(...)]

// Especifica examples para mejor UX
#[OA\Property(example: 'john@example.com')]

// Usa Models para DTOs y Entities
ref: new Model(type: User::class, groups: ['user:read'])

// Documenta todos los response codes posibles
responses: [
    new OA\Response(response: 200, ...),
    new OA\Response(response: 400, ...),
    new OA\Response(response: 401, ...),
    new OA\Response(response: 404, ...),
]

// Usa tags para organizar endpoints
tags: ['Users']
```

### ❌ DON'T

```php
// No duplicar documentación en PHPDoc y atributos
/** @OA\Post(...) */
#[OA\Post(...)] // Elige uno

// No documentar passwords en responses
#[Groups(['user:read'])]
private string $password; // NUNCA

// No hardcodear URLs
servers:
    - url: http://localhost:8000 // MAL
// Usa variables de entorno

// No dejar responses sin documentar
#[OA\Post(...)] // Sin responses: []
```

---

## Swagger UI

Accede a la documentación interactiva en:
```
/api/doc
```

Features:
- Try it out (ejecuta requests desde el browser)
- Authorize (añade tokens JWT)
- Download OpenAPI spec (JSON/YAML)
- Generate client SDKs

---

## 🔄 Auto-Mantenimiento con Context7

**Library tracked:** `/nelmio/api-doc-bundle`

**Actualización automática:**
```
mcp__context7__resolve-library-id: libraryName="NelmioApiDocBundle"
mcp__context7__query-docs: libraryId="/nelmio/api-doc-bundle", query="latest OpenAPI 3.1 features and Symfony integration"
```

**Qué se actualiza:**
- ✅ Nuevas features de OpenAPI 3.1
- ✅ Nuevos atributos disponibles
- ✅ Breaking changes en Nelmio
- ✅ Integración con Symfony 7+
- ✅ Security schemes nuevos

**Qué se preserva:**
- ✅ Estructura de documentación existente
- ✅ Tags y organización
- ✅ Examples personalizados
- ✅ Security schemes configurados

**Frecuencia:** Automática cuando detecta nueva versión

**Última sync:** 2026-02-04
**Versión tracked:** OpenAPI 3.1 / Nelmio 4.x

---

*Organismo viviente: Context7 + Experiencia comunitaria + Tu uso*
