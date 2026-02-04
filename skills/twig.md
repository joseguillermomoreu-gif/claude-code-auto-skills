# Twig - Template Engine for Symfony

**Versión:** 1.0.0
**Última actualización:** 2026-02-04
**Auto-mantenimiento:** Context7 enabled

---

## Introducción

Twig es el motor de plantillas oficial de Symfony, diseñado para ser rápido, seguro y flexible.

**Características:**
- Auto-escaping por defecto (seguridad XSS)
- Herencia de templates
- Sintaxis concisa y legible
- Compilado a PHP optimizado
- Extensible con filtros y funciones custom

---

## Sintaxis Básica

### Delimiters

```twig
{# Comentario #}
{{ variable }}          {# Output #}
{% control_structure %} {# Lógica #}
```

### Variables

```twig
{{ name }}
{{ user.name }}
{{ user['email'] }}
{{ user.getName() }}

{# Con filtro #}
{{ name|upper }}
{{ price|number_format(2, ',', '.') }}

{# Default value #}
{{ description|default('No description available') }}
```

---

## Estructuras de Control

### If

```twig
{% if user.isActive %}
    <p>Active user</p>
{% elseif user.isPending %}
    <p>Pending approval</p>
{% else %}
    <p>Inactive</p>
{% endif %}

{# Operadores #}
{% if age >= 18 and hasLicense %}
{% if role == 'admin' or role == 'moderator' %}
{% if not isExpired %}
{% if 'admin' in user.roles %}
```

### For

```twig
{% for product in products %}
    <div>{{ product.name }}</div>
{% endfor %}

{# Con key #}
{% for key, value in data %}
    {{ key }}: {{ value }}
{% endfor %}

{# Loop variable #}
{% for user in users %}
    {{ loop.index }}: {{ user.name }}
    {% if loop.first %} (first) {% endif %}
    {% if loop.last %} (last) {% endif %}
    {{ loop.length }} {# Total items #}
{% endfor %}

{# Else (empty array) #}
{% for item in items %}
    {{ item.name }}
{% else %}
    <p>No items found</p>
{% endfor %}
```

---

## Herencia de Templates

### Layout Base

**base.html.twig:**
```twig
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{% block title %}Default Title{% endblock %}</title>

    {% block stylesheets %}
        <link rel="stylesheet" href="{{ asset('css/app.css') }}">
    {% endblock %}
</head>
<body>
    {% block header %}
        <header>
            <h1>{{ app_name }}</h1>
        </header>
    {% endblock %}

    {% block body %}{% endblock %}

    {% block footer %}
        <footer>&copy; {{ 'now'|date('Y') }} My Company</footer>
    {% endblock %}

    {% block javascripts %}
        <script src="{{ asset('js/app.js') }}"></script>
    {% endblock %}
</body>
</html>
```

### Template Hijo

**pages/home.html.twig:**
```twig
{% extends 'base.html.twig' %}

{% block title %}Home Page{% endblock %}

{% block stylesheets %}
    {{ parent() }}  {# Include parent styles #}
    <link rel="stylesheet" href="{{ asset('css/home.css') }}">
{% endblock %}

{% block body %}
    <h2>Welcome!</h2>

    {% for article in articles %}
        <article>
            <h3>{{ article.title }}</h3>
            <p>{{ article.summary|raw }}</p>
        </article>
    {% endfor %}
{% endblock %}

{% block javascripts %}
    {{ parent() }}
    <script src="{{ asset('js/home.js') }}"></script>
{% endblock %}
```

---

## Includes

```twig
{# Include simple #}
{% include 'partials/header.html.twig' %}

{# Include con variables #}
{% include 'partials/user-card.html.twig' with {'user': currentUser} %}

{# Include sin contexto (solo variables pasadas) #}
{% include 'partials/menu.html.twig' with {'items': menuItems} only %}

{# Include condicional #}
{% if showSidebar %}
    {% include 'partials/sidebar.html.twig' %}
{% endif %}
```

---

## Embed (Include + Herencia)

```twig
{# Define blocks dentro de include #}
{% embed 'partials/card.html.twig' %}
    {% block title %}My Custom Title{% endblock %}
    {% block content %}
        <p>Custom content here</p>
    {% endblock %}
{% endembed %}
```

**partials/card.html.twig:**
```twig
<div class="card">
    <h3>{% block title %}{% endblock %}</h3>
    <div class="card-body">
        {% block content %}{% endblock %}
    </div>
</div>
```

---

## Filtros

### Filtros Built-in

```twig
{# String #}
{{ name|upper }}                      {# UPPERCASE #}
{{ name|lower }}                      {# lowercase #}
{{ name|capitalize }}                 {# Capitalize #}
{{ name|title }}                      {# Title Case #}
{{ text|trim }}                       {# Remove whitespace #}
{{ html|striptags }}                  {# Remove HTML #}
{{ text|nl2br }}                      {# Newlines to <br> #}
{{ text|wordwrap(80) }}               {# Wrap text #}

{# Arrays #}
{{ items|length }}                    {# Count #}
{{ items|join(', ') }}                {# Implode #}
{{ items|first }}                     {# First element #}
{{ items|last }}                      {# Last element #}
{{ items|reverse }}                   {# Reverse #}
{{ items|slice(0, 5) }}               {# Array slice #}
{{ items|sort }}                      {# Sort #}
{{ items|merge(otherItems) }}         {# Merge arrays #}

{# Escape #}
{{ html|escape }}                     {# HTML escape (default) #}
{{ html|e }}                          {# Shorthand #}
{{ html|raw }}                        {# No escape (dangerous!) #}
{{ json|json_encode }}                {# JSON encode #}

{# Dates #}
{{ date|date('Y-m-d') }}
{{ date|date('F j, Y') }}
{{ date|format_datetime('short') }}   {# Symfony helper #}

{# Numbers #}
{{ price|number_format(2, ',', '.') }}
{{ number|abs }}                      {# Absolute #}
{{ number|round }}                    {# Round #}
{{ number|round(2, 'floor') }}        {# Round down to 2 decimals #}

{# URLs #}
{{ url|url_encode }}

{# Default #}
{{ variable|default('N/A') }}
{{ variable|default('N/A')|upper }}   {# Chainable #}
```

### Filtros Symfony

```twig
{# Translation #}
{{ 'app.welcome'|trans }}
{{ 'app.greeting'|trans({'%name%': user.name}) }}

{# Format #}
{{ price|format_currency('EUR') }}
{{ date|format_datetime }}
{{ number|format_number }}

{# Markdown #}
{{ content|markdown_to_html }}

{# Yaml/Json #}
{{ data|yaml_encode }}
{{ data|yaml_decode }}
```

### Custom Filter

```php
// src/Twig/AppExtension.php
namespace App\Twig;

use Twig\Extension\AbstractExtension;
use Twig\TwigFilter;

class AppExtension extends AbstractExtension
{
    public function getFilters(): array
    {
        return [
            new TwigFilter('price', [$this, 'formatPrice']),
        ];
    }

    public function formatPrice(float $price): string
    {
        return number_format($price, 2, ',', '.') . ' €';
    }
}
```

**Uso:**
```twig
{{ product.price|price }}  {# 99,99 € #}
```

---

## Funciones

### Funciones Built-in

```twig
{# Range #}
{% for i in range(1, 10) %}
    {{ i }}
{% endfor %}

{# Max/Min #}
{{ max(1, 5, 3) }}  {# 5 #}
{{ min(prices) }}

{# Random #}
{{ random(['apple', 'banana', 'orange']) }}
{{ random(100) }}  {# Random number 0-100 #}

{# Date #}
{{ date() }}                    {# Current datetime #}
{{ date('now') }}
{{ date('+1 day') }}

{# Dump (dev only) #}
{{ dump(variable) }}
```

### Funciones Symfony

```twig
{# Routing #}
{{ path('app_user_profile', {'id': user.id}) }}
{{ url('app_homepage') }}  {# Absolute URL #}

{# Assets #}
{{ asset('images/logo.png') }}
{{ asset('build/app.css') }}

{# Controller #}
{{ render(controller('App\\Controller\\MenuController::index')) }}
{{ render(path('app_menu')) }}

{# Translation #}
{{ 'app.welcome'|trans }}

{# Security #}
{% if is_granted('ROLE_ADMIN') %}
    <a href="{{ path('admin_dashboard') }}">Admin</a>
{% endif %}

{# CSRF #}
<input type="hidden" name="_token" value="{{ csrf_token('delete-item') }}">

{# Forms #}
{{ form_start(form) }}
{{ form_widget(form) }}
{{ form_end(form) }}
```

### Custom Function

```php
public function getFunctions(): array
{
    return [
        new TwigFunction('area', [$this, 'calculateArea']),
    ];
}

public function calculateArea(float $width, float $height): float
{
    return $width * $height;
}
```

**Uso:**
```twig
{{ area(5, 10) }}  {# 50 #}
```

---

## Macros

```twig
{# Define macro #}
{% macro input(name, value, type = 'text') %}
    <input type="{{ type }}"
           name="{{ name }}"
           value="{{ value|default('') }}"
           class="form-control">
{% endmacro %}

{# Use macro #}
{% import _self as forms %}
{{ forms.input('username', user.name) }}
{{ forms.input('email', user.email, 'email') }}
```

**En archivo separado:**

**macros/forms.html.twig:**
```twig
{% macro input(name, value, type = 'text') %}
    <input type="{{ type }}" name="{{ name }}" value="{{ value }}">
{% endmacro %}

{% macro button(text, type = 'submit') %}
    <button type="{{ type }}" class="btn">{{ text }}</button>
{% endmacro %}
```

**Uso:**
```twig
{% import 'macros/forms.html.twig' as forms %}

{{ forms.input('username', user.name) }}
{{ forms.button('Submit') }}
```

---

## Tests (Operadores)

```twig
{# defined #}
{% if variable is defined %}

{# null/empty #}
{% if variable is null %}
{% if variable is empty %}  {# null, false, [], '' #}

{# Types #}
{% if variable is iterable %}
{% if variable is string %}
{% if variable is number %}

{# Comparison #}
{% if user is same as(currentUser) %}

{# even/odd #}
{% if loop.index is even %}
{% if loop.index is odd %}

{# divisible by #}
{% if number is divisible by(3) %}
```

---

## Auto-escape

```twig
{# Default: auto-escape ON #}
{{ userInput }}  {# Escaped #}

{# Disable (dangerous!) #}
{% autoescape false %}
    {{ trustedHtml }}
{% endautoescape %}

{# O usar filtro raw #}
{{ trustedHtml|raw }}

{# Escape strategy #}
{% autoescape 'js' %}
    {{ jsVariable }}
{% endautoescape %}

{% autoescape 'html' %}
    {{ htmlContent }}
{% endautoescape %}
```

---

## Whitespace Control

```twig
{# Trim whitespace #}
{{- variable -}}     {# No whitespace around #}

{% for item in items -%}
    {{ item.name }}
{%- endfor %}        {# Compact output #}

{# Spaceless (deprecated, use CSS minifier instead) #}
{% spaceless %}
    <div>
        <strong>Content</strong>
    </div>
{% endspaceless %}
{# Output: <div><strong>Content</strong></div> #}
```

---

## Set Variables

```twig
{% set foo = 'bar' %}
{{ foo }}

{% set total = price * quantity %}

{% set items = [1, 2, 3] %}

{% set user = {
    'name': 'John',
    'email': 'john@example.com'
} %}

{# Capture block #}
{% set content %}
    <p>Captured content</p>
{% endset %}
```

---

## Symfony Integration

### Controller

```php
namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;

class HomeController extends AbstractController
{
    public function index(): Response
    {
        return $this->render('pages/home.html.twig', [
            'title' => 'Welcome',
            'articles' => $this->getArticles(),
        ]);
    }
}
```

### Forms

```twig
{{ form_start(form) }}

    {{ form_row(form.name) }}
    {{ form_row(form.email) }}

    {# Custom rendering #}
    <div class="form-group">
        {{ form_label(form.password) }}
        {{ form_widget(form.password, {'attr': {'class': 'form-control'}}) }}
        {{ form_errors(form.password) }}
        {{ form_help(form.password) }}
    </div>

    <button type="submit" class="btn">Submit</button>

{{ form_end(form) }}
```

### Flash Messages

```twig
{% for message in app.flashes('success') %}
    <div class="alert alert-success">
        {{ message }}
    </div>
{% endfor %}

{% for message in app.flashes('error') %}
    <div class="alert alert-danger">
        {{ message }}
    </div>
{% endfor %}
```

### Global Variables

```twig
{# App context #}
{{ app.request.get('page') }}
{{ app.request.headers.get('User-Agent') }}
{{ app.session.get('cart_id') }}
{{ app.user.email }}  {# If authenticated #}
{{ app.environment }}  {# dev, prod, etc. #}

{# Check auth #}
{% if app.user %}
    <p>Welcome, {{ app.user.username }}</p>
{% endif %}

{% if is_granted('ROLE_ADMIN') %}
    <a href="{{ path('admin') }}">Admin Panel</a>
{% endif %}
```

---

## Best Practices

### ✅ DO

```twig
{# Use blocks for extensibility #}
{% block content %}{% endblock %}

{# Descriptive variable names #}
{% for product in products %}  {# Not: item in items #}

{# Include partials for reusable components #}
{% include 'partials/pagination.html.twig' %}

{# Use macros for repeated HTML patterns #}
{{ forms.input('email', user.email) }}

{# Let auto-escape protect you #}
{{ userInput }}  {# Escaped by default #}

{# Translation keys #}
{{ 'app.welcome_message'|trans }}

{# Asset function for versioning #}
{{ asset('css/app.css') }}  {# Not: /css/app.css #}
```

### ❌ DON'T

```twig
{# No business logic in templates #}
{% set total = 0 %}
{% for item in cart %}
    {% set total = total + (item.price * item.quantity) %}
{% endfor %}
{# ❌ Do this in controller/service #}

{# No database queries #}
{% set users = entity_manager.getRepository('App:User').findAll() %}
{# ❌ Pass data from controller #}

{# Don't abuse |raw #}
{{ content|raw }}  {# ⚠️ XSS risk if content is user-generated #}

{# Don't disable auto-escape globally #}
{% autoescape false %}  {# ❌ Dangerous #}
```

---

## Performance

```yaml
# config/packages/twig.yaml
twig:
    # Cache compiled templates (production)
    cache: '%kernel.cache_dir%/twig'

    # Disable cache in dev
    auto_reload: '%kernel.debug%'

    # Strict variables (error on undefined)
    strict_variables: '%kernel.debug%'

    # Optimizations
    optimizations: -1  {# All optimizations enabled #}
```

**Tips:**
1. Use `{% cache %}` for expensive renders
2. Minimize includes (each is a file read)
3. Use asset versioning for browser cache
4. Lazy load macros (don't import if not used)

---

## Debugging

```twig
{# Dump variable (dev only) #}
{{ dump(user) }}
{{ dump(user, products, cart) }}

{# Check if defined #}
{% if variable is defined %}
    {{ variable }}
{% else %}
    Variable not defined
{% endif %}

{# Debug mode check #}
{% if app.debug %}
    <pre>{{ dump(data) }}</pre>
{% endif %}
```

---

## 🔄 Auto-Mantenimiento con Context7

**Library tracked:** `/symfony/twig`

**Actualización automática:**
```
mcp__context7__resolve-library-id: libraryName="Twig"
mcp__context7__query-docs: libraryId="/symfony/twig", query="latest Twig template engine features and Symfony integration"
```

**Qué se actualiza:**
- ✅ Nuevos filtros y funciones
- ✅ Sintaxis mejorada Twig 3.x+
- ✅ Integración Symfony 7+
- ✅ Security best practices
- ✅ Performance optimizations

**Qué se preserva:**
- ✅ Patrones de uso establecidos
- ✅ Macros custom
- ✅ Estructura de layouts preferida
- ✅ Extensiones personalizadas

**Frecuencia:** Automática cuando detecta nueva versión

**Última sync:** 2026-02-04
**Versión tracked:** Twig 3.x / Symfony 7.x

---

*Organismo viviente: Context7 + Experiencia comunitaria + Tu uso*
