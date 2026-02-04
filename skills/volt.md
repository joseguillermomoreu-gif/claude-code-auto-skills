# Volt - Template Engine (Phalcon/Symfony)

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Context7 enabled

---

## Introducción

Volt es un motor de plantillas rápido y potente integrado en Phalcon, inspirado en Jinja/Twig. También disponible como componente standalone para Symfony y otros frameworks.

**Características:**
- Sintaxis limpia y fácil de leer
- Compilado a PHP nativo (rápido)
- Herencia de templates
- Filtros y funciones incorporadas
- Extensible con funciones custom

---

## Sintaxis Básica

### Variables

```volt
{# Mostrar variable #}
{{ username }}
{{ user.name }}
{{ user['email'] }}

{# Con filtro #}
{{ title|upper }}
{{ price|number_format(2, ',', '.') }}

{# Default value #}
{{ description|default('No description') }}
```

### Comentarios

```volt
{# Esto es un comentario #}

{#
    Comentario
    multi-línea
#}
```

### Estructuras de Control

```volt
{# If #}
{% if user.isActive %}
    <p>User is active</p>
{% elseif user.isPending %}
    <p>User is pending</p>
{% else %}
    <p>User is inactive</p>
{% endif %}

{# For loop #}
{% for product in products %}
    <div class="product">
        <h3>{{ product.name }}</h3>
        <p>{{ product.price }}</p>
    </div>
{% endfor %}

{# For con índice #}
{% for key, product in products %}
    {{ key }}: {{ product.name }}
{% endfor %}

{# Loop variable #}
{% for item in items %}
    {{ loop.index }}: {{ item.name }}
    {% if loop.first %} (primero) {% endif %}
    {% if loop.last %} (último) {% endif %}
{% endfor %}

{# For con else (si array vacío) #}
{% for product in products %}
    <p>{{ product.name }}</p>
{% else %}
    <p>No products found</p>
{% endfor %}
```

---

## Herencia de Templates

### Layout Base

**layouts/main.volt:**
```volt
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Default Title{% endblock %}</title>

    {% block styles %}
        <link rel="stylesheet" href="/css/main.css">
    {% endblock %}
</head>
<body>
    <header>
        {% block header %}
            <h1>My Website</h1>
        {% endblock %}
    </header>

    <main>
        {% block content %}
            {# Contenido por defecto #}
        {% endblock %}
    </main>

    <footer>
        {% block footer %}
            <p>&copy; 2026 My Company</p>
        {% endblock %}
    </footer>

    {% block scripts %}
        <script src="/js/main.js"></script>
    {% endblock %}
</body>
</html>
```

### Template Hijo

**pages/home.volt:**
```volt
{% extends "layouts/main.volt" %}

{% block title %}Home Page{% endblock %}

{% block styles %}
    {{ parent() }}  {# Include parent styles #}
    <link rel="stylesheet" href="/css/home.css">
{% endblock %}

{% block content %}
    <h2>Welcome!</h2>
    <p>This is the home page.</p>

    {% for article in articles %}
        <article>
            <h3>{{ article.title }}</h3>
            <p>{{ article.summary }}</p>
        </article>
    {% endfor %}
{% endblock %}

{% block scripts %}
    {{ parent() }}
    <script src="/js/home.js"></script>
{% endblock %}
```

---

## Includes y Partials

```volt
{# Include simple #}
{% include "partials/header.volt" %}

{# Include con variables #}
{% include "partials/user-card.volt" with {'user': currentUser} %}

{# Include condicional #}
{% if showSidebar %}
    {% include "partials/sidebar.volt" %}
{% endif %}
```

**partials/user-card.volt:**
```volt
<div class="user-card">
    <img src="{{ user.avatar }}" alt="{{ user.name }}">
    <h3>{{ user.name }}</h3>
    <p>{{ user.email }}</p>
</div>
```

---

## Filtros

### Filtros Built-in

```volt
{# String #}
{{ name|upper }}                    {# UPPERCASE #}
{{ name|lower }}                    {# lowercase #}
{{ name|capitalize }}               {# Capitalize first #}
{{ name|title }}                    {# Title Case #}
{{ name|trim }}                     {# Remove whitespace #}
{{ name|striptags }}                {# Remove HTML tags #}
{{ content|nl2br }}                 {# Newlines to <br> #}

{# Escape #}
{{ html|e }}                        {# HTML escape #}
{{ html|escape }}                   {# Same #}
{{ json|json_encode }}              {# JSON encode #}

{# Arrays #}
{{ items|length }}                  {# Count #}
{{ items|join(', ') }}              {# Implode #}
{{ items|first }}                   {# First element #}
{{ items|last }}                    {# Last element #}
{{ items|reverse }}                 {# Reverse array #}

{# Numbers #}
{{ price|number_format(2, ',', '.') }}
{{ value|abs }}                     {# Absolute value #}
{{ value|round }}                   {# Round #}

{# Dates #}
{{ date|date('Y-m-d H:i:s') }}
{{ timestamp|date('d/m/Y') }}

{# Default #}
{{ variable|default('N/A') }}
```

### Encadenar Filtros

```volt
{{ name|trim|lower|capitalize }}
{{ price|number_format(2)|default('Free') }}
```

### Filtros Personalizados

**Phalcon:**
```php
// In controller or service
$volt = $this->view->getCompiler();

$volt->addFilter('shout', function($resolvedArgs) {
    return 'strtoupper(' . $resolvedArgs . ') . "!!!"';
});
```

**Uso:**
```volt
{{ name|shout }}  {# JOHN!!! #}
```

---

## Funciones

### Funciones Built-in

```volt
{# URL generation #}
{{ url('users/profile/123') }}
{{ static_url('css/style.css') }}

{# Content #}
{{ content() }}                     {# Render view content #}
{{ partial('partials/menu') }}      {# Render partial #}

{# Assets #}
{{ stylesheet_link('css/main.css') }}
{{ javascript_include('js/app.js') }}

{# Debugging #}
{{ dump(variable) }}
```

### Funciones Personalizadas

```php
$volt->addFunction('formatCurrency', function($resolvedArgs) {
    return "number_format($resolvedArgs, 2, ',', '.') . ' €'";
});
```

**Uso:**
```volt
{{ formatCurrency(product.price) }}  {# 99,99 € #}
```

---

## Macros

```volt
{# Define macro #}
{% macro input(name, value, type = "text") %}
    <input type="{{ type }}"
           name="{{ name }}"
           value="{{ value }}"
           class="form-control">
{% endmacro %}

{# Use macro #}
{{ input('username', user.name) }}
{{ input('email', user.email, 'email') }}
{{ input('password', '', 'password') }}
```

**Con imports:**
```volt
{# forms.volt #}
{% macro input(name, value) %}
    <input name="{{ name }}" value="{{ value }}">
{% endmacro %}

{% macro button(text, type = 'submit') %}
    <button type="{{ type }}" class="btn">{{ text }}</button>
{% endmacro %}

{# En otro template #}
{% import "macros/forms.volt" as forms %}

{{ forms.input('username', user.name) }}
{{ forms.button('Submit') }}
```

---

## Configuración Phalcon

### Setup Básico

```php
use Phalcon\Mvc\View;
use Phalcon\Mvc\View\Engine\Volt;

$di->set('view', function() {
    $view = new View();
    $view->setViewsDir(__DIR__ . '/../views/');

    $view->registerEngines([
        '.volt' => function($view, $di) {
            $volt = new Volt($view, $di);

            $volt->setOptions([
                'path' => __DIR__ . '/../cache/volt/',
                'separator' => '_',
                'stat' => true, // Check changes in dev
                'compileAlways' => false // Recompile only if changed
            ]);

            return $volt;
        }
    ]);

    return $view;
});
```

### Development vs Production

```php
$volt->setOptions([
    'path' => __DIR__ . '/../cache/volt/',

    // Development
    'stat' => true,          // Check file changes
    'compileAlways' => true, // Always recompile (slower)

    // Production
    'stat' => false,          // No checks (faster)
    'compileAlways' => false, // Cache compiled templates
]);
```

---

## Configuración Symfony (Standalone)

```bash
composer require phalcon/volt
```

```php
use Phalcon\Mvc\View\Engine\Volt\Compiler;

class VoltExtension extends AbstractExtension
{
    private Compiler $volt;

    public function __construct()
    {
        $this->volt = new Compiler();
        $this->volt->setOptions([
            'path' => __DIR__ . '/../../var/cache/volt/'
        ]);
    }

    // Custom filters, functions, etc.
}
```

---

## Espacios en Blanco

```volt
{# Eliminar espacios #}
{{- variable -}}     {# No whitespace before/after #}

{% for item in items -%}
    {{ item.name }}
{%- endfor %}        {# Compact output #}
```

---

## Auto-escape

```volt
{# Por defecto: auto-escape ON #}
{{ html }}  {# Escaped #}

{# Disable auto-escape #}
{% autoescape false %}
    {{ html }}  {# Raw HTML #}
{% endautoescape %}

{# O usar filtro raw #}
{{ html|raw }}
```

---

## Operadores

```volt
{# Comparison #}
{% if age >= 18 %}
{% if status == 'active' %}
{% if price > 100 %}

{# Logical #}
{% if user and user.isActive %}
{% if isAdmin or isModerator %}
{% if not isExpired %}

{# Arithmetic #}
{{ price * quantity }}
{{ total + tax }}
{{ discount / 100 }}

{# Ternary #}
{{ status == 'active' ? 'Active' : 'Inactive' }}
{{ user.name ?: 'Guest' }}

{# Null coalescing #}
{{ user.phone ?? 'N/A' }}

{# Concatenation #}
{{ firstName ~ ' ' ~ lastName }}

{# Containment #}
{% if 'admin' in user.roles %}
```

---

## Set Variables

```volt
{% set total = price * quantity %}
{{ total }}

{% set items = [1, 2, 3, 4, 5] %}

{% set user = {
    'name': 'John',
    'email': 'john@example.com'
} %}
```

---

## Best Practices

### ✅ DO

```volt
{# Usa herencia para layouts #}
{% extends "layouts/main.volt" %}

{# Separa lógica de presentación #}
{% for product in products %}  {# Controller pasa products #}

{# Usa filtros para formateo #}
{{ price|number_format(2) }}

{# Escape by default #}
{{ userInput }}  {# Auto-escaped #}

{# Macros para componentes reusables #}
{{ forms.input('name', user.name) }}
```

### ❌ DON'T

```volt
{# No lógica de negocio en templates #}
{% set total = 0 %}
{% for item in items %}
    {% set total = total + item.price * item.qty %}
{% endfor %}
{# ❌ Esto debe hacerse en controller/service #}

{# No consultas a base de datos #}
{% set users = model.find() %}  {# ❌ #}

{# No abuso de raw/autoescape false #}
{{ content|raw }}  {# ⚠️ Solo si confías en el contenido #}
```

---

## Debugging

```volt
{# Dump variable #}
{{ dump(variable) }}
{{ dump(user) }}

{# Check if defined #}
{% if variable is defined %}
    {{ variable }}
{% endif %}

{# Debug block #}
{% if debug %}
    <pre>{{ dump(data) }}</pre>
{% endif %}
```

---

## Performance Tips

1. **Use compiled templates in production:**
   ```php
   'compileAlways' => false,
   'stat' => false
   ```

2. **Cache partials:**
   ```php
   $this->view->cache(['key' => 'sidebar', 'lifetime' => 3600]);
   ```

3. **Avoid complex logic in templates:**
   - Process data in controller
   - Use view models/DTOs

4. **Minimize includes:**
   - Too many includes = slower
   - Combine related partials

---

## 🔄 Auto-Mantenimiento con Context7

**Library tracked:** `/phalcon/volt`

**Actualización automática:**
```
mcp__context7__resolve-library-id: libraryName="Phalcon Volt"
mcp__context7__query-docs: libraryId="/phalcon/volt", query="latest Volt template engine features"
```

**Qué se actualiza:**
- ✅ Nuevos filtros y funciones
- ✅ Sintaxis mejorada
- ✅ Performance optimizations
- ✅ Breaking changes en versiones mayores
- ✅ Security best practices

**Qué se preserva:**
- ✅ Patrones de uso establecidos
- ✅ Macros y helpers custom
- ✅ Estructura de layouts preferida

**Frecuencia:** Automática cuando detecta nueva versión

**Última sync:** 2026-02-04
**Versión tracked:** Volt 4.x / Phalcon 5.x

---

*Organismo viviente: Context7 + Experiencia comunitaria + Tu uso*
