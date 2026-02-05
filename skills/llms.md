# LLMs - Large Language Models

> **Audiencia**: Desarrolladores trabajando con LLMs (OpenAI, Claude, Gemini, etc.)
> **Última actualización**: 2026-02-05
> **Enfoque**: Patrones, prompt engineering, integración en aplicaciones

## Conceptos Fundamentales

### ¿Qué es un LLM?

Un **Large Language Model** es un modelo de IA entrenado con grandes cantidades de texto para:
- Comprender y generar lenguaje natural
- Seguir instrucciones complejas
- Razonar sobre problemas
- Generar código
- Analizar y resumir información

### Principales Proveedores

| Provider | Modelos Principales | Fortalezas |
|----------|---------------------|------------|
| **OpenAI** | GPT-4o, GPT-4, GPT-3.5 | Chat, razonamiento general, function calling |
| **Anthropic** | Claude 4.5 (Opus/Sonnet/Haiku) | Razonamiento profundo, largos contextos (200K tokens) |
| **Google** | Gemini Pro/Ultra, PaLM | Multimodal, integración Google |
| **Meta** | Llama 3, Code Llama | Open source, on-premise |
| **Mistral** | Mixtral 8x7B, Mistral Large | Europeo, open-source |

### Características Clave

```
Context Window: Cantidad de tokens que el modelo puede procesar a la vez
├─ GPT-4o: 128K tokens
├─ Claude 4.5: 200K tokens
├─ Gemini Pro: 1M tokens
└─ Llama 3: 8K-32K tokens

Temperature: Controla la aleatoriedad de las respuestas
├─ 0.0: Determinista, misma respuesta siempre (ideal para tareas precisas)
├─ 0.7: Balanceado (conversación general)
└─ 1.0+: Creativo, respuestas variadas (brainstorming)

Top-p (nucleus sampling): Alternativa a temperature
└─ 0.9: Considera solo el 90% de tokens más probables
```

---

## Prompt Engineering

### Principios KISS para Prompts

**1. Sea específico y directo**

```python
# ❌ MAL: Vago
prompt = "Escribe código para usuarios"

# ✅ BIEN: Específico
prompt = """
Escribe una función Python que:
1. Valide un email usando regex
2. Retorne True/False
3. Incluya type hints
4. Tenga docstring con ejemplos
"""
```

**2. Use ejemplos (Few-Shot Learning)**

```python
# Few-shot: Enseña con ejemplos
prompt = """
Convierte estas frases a JSON:

Entrada: "Juan tiene 30 años y vive en Madrid"
Salida: {"nombre": "Juan", "edad": 30, "ciudad": "Madrid"}

Entrada: "María es ingeniera y trabaja en Barcelona"
Salida: {"nombre": "María", "profesion": "ingeniera", "ciudad": "Barcelona"}

Ahora hazlo con:
Entrada: "Pedro es médico, tiene 45 años y vive en Valencia"
Salida:
"""
```

**3. Chain of Thought (Razonamiento paso a paso)**

```python
# ✅ Fuerza al modelo a razonar
prompt = """
Resuelve este problema paso a paso:

Problema: Una empresa tiene 100 empleados. El 40% trabaja remoto.
De los que trabajan remoto, el 60% son desarrolladores.
¿Cuántos desarrolladores trabajan remoto?

Razonamiento:
1. [Primero calcula los empleados remotos]
2. [Luego calcula desarrolladores remotos]

Respuesta final:
"""
```

**4. Estructura clara con roles**

```python
messages = [
    {
        "role": "system",
        "content": "Eres un experto en Python senior. Responde con código limpio y type hints."
    },
    {
        "role": "user",
        "content": "Crea una función que calcule factorial recursivamente"
    }
]
```

### Anti-Patrones Comunes

```python
# ❌ Prompt demasiado largo sin estructura
prompt = "hola necesito que me hagas una función que..."  # 500 palabras más

# ✅ Estructura con secciones
prompt = """
## Tarea
Crear función de autenticación JWT

## Requisitos
- Input: email, password
- Output: token JWT
- Validar credenciales contra DB
- Token expira en 1h

## Tecnologías
- Python 3.12
- PyJWT library
- SQLAlchemy

## Formato de respuesta
Solo código, sin explicaciones.
"""

# ❌ Asumir contexto implícito
prompt = "Mejora este código"  # ¿Qué código?

# ✅ Incluye todo el contexto necesario
prompt = """
Mejora este código Python:

```python
def calc(x, y):
    return x + y
```

Mejoras necesarias:
- Type hints
- Docstring
- Validación de inputs
- Manejo de errores
"""
```

---

## Patrones de Integración

### 1. Wrapper Genérico para LLM

```python
# src/infrastructure/llm_client.py
from abc import ABC, abstractmethod
from typing import List, Dict, Optional
from dataclasses import dataclass

@dataclass
class Message:
    role: str  # "system", "user", "assistant"
    content: str

class LLMProvider(ABC):
    """Interface para diferentes proveedores LLM"""

    @abstractmethod
    def complete(
        self,
        messages: List[Message],
        model: str,
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
    ) -> str:
        pass

class OpenAIProvider(LLMProvider):
    def __init__(self, api_key: str):
        from openai import OpenAI
        self.client = OpenAI(api_key=api_key)

    def complete(
        self,
        messages: List[Message],
        model: str = "gpt-4o",
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
    ) -> str:
        response = self.client.chat.completions.create(
            model=model,
            messages=[{"role": m.role, "content": m.content} for m in messages],
            temperature=temperature,
            max_tokens=max_tokens,
        )
        return response.choices[0].message.content

class ClaudeProvider(LLMProvider):
    def __init__(self, api_key: str):
        from anthropic import Anthropic
        self.client = Anthropic(api_key=api_key)

    def complete(
        self,
        messages: List[Message],
        model: str = "claude-sonnet-4-5-20250929",
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
    ) -> str:
        # Separar system message
        system_msg = next((m.content for m in messages if m.role == "system"), None)
        user_messages = [
            {"role": m.role, "content": m.content}
            for m in messages if m.role != "system"
        ]

        response = self.client.messages.create(
            model=model,
            system=system_msg,
            messages=user_messages,
            temperature=temperature,
            max_tokens=max_tokens or 4096,
        )
        return response.content[0].text

# Factory pattern
def create_llm_provider(provider: str, api_key: str) -> LLMProvider:
    providers = {
        "openai": OpenAIProvider,
        "claude": ClaudeProvider,
    }
    return providers[provider](api_key)
```

### 2. Retry con Exponential Backoff

```python
import time
from typing import Callable, TypeVar

T = TypeVar("T")

def retry_with_backoff(
    func: Callable[[], T],
    max_retries: int = 3,
    initial_delay: float = 1.0,
    backoff_factor: float = 2.0,
) -> T:
    """
    Reintentar llamada con backoff exponencial.
    Útil para errores de rate limit.
    """
    delay = initial_delay

    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise

            print(f"Error en intento {attempt + 1}: {e}")
            print(f"Reintentando en {delay}s...")
            time.sleep(delay)
            delay *= backoff_factor

    raise RuntimeError("No debería llegar aquí")

# Uso
response = retry_with_backoff(
    lambda: client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": "Hello"}]
    )
)
```

### 3. Streaming de Respuestas

```python
def stream_completion(prompt: str, model: str = "gpt-4o"):
    """
    Stream de respuesta token por token.
    Ideal para UIs interactivas.
    """
    from openai import OpenAI
    client = OpenAI()

    stream = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        stream=True,
    )

    for chunk in stream:
        if chunk.choices[0].delta.content:
            content = chunk.choices[0].delta.content
            print(content, end="", flush=True)
            yield content

# Uso
for token in stream_completion("Explica qué es un LLM"):
    # Procesar token (ej: enviar a WebSocket)
    pass
```

### 4. Function Calling (Tool Use)

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Obtiene el clima de una ciudad",
            "parameters": {
                "type": "object",
                "properties": {
                    "city": {
                        "type": "string",
                        "description": "Nombre de la ciudad"
                    },
                    "units": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"]
                    }
                },
                "required": ["city"]
            }
        }
    }
]

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "user", "content": "¿Qué tiempo hace en Madrid?"}
    ],
    tools=tools,
    tool_choice="auto",
)

# Si el modelo decide usar la función
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    function_name = tool_call.function.name
    function_args = json.loads(tool_call.function.arguments)

    # Ejecutar la función
    if function_name == "get_weather":
        result = get_weather(**function_args)

        # Enviar resultado de vuelta al modelo
        messages.append(response.choices[0].message)
        messages.append({
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps(result)
        })

        # Segunda llamada con el resultado
        final_response = client.chat.completions.create(
            model="gpt-4o",
            messages=messages
        )
```

---

## Costos y Optimización

### Estimación de Costos

```python
# Precios aproximados (Feb 2026)
PRICING = {
    "gpt-4o": {
        "input": 2.50 / 1_000_000,   # $2.50 por 1M tokens
        "output": 10.00 / 1_000_000,  # $10.00 por 1M tokens
    },
    "gpt-4": {
        "input": 30.00 / 1_000_000,
        "output": 60.00 / 1_000_000,
    },
    "gpt-3.5-turbo": {
        "input": 0.50 / 1_000_000,
        "output": 1.50 / 1_000_000,
    },
    "claude-sonnet-4": {
        "input": 3.00 / 1_000_000,
        "output": 15.00 / 1_000_000,
    },
}

def estimate_cost(
    input_tokens: int,
    output_tokens: int,
    model: str = "gpt-4o"
) -> float:
    """Calcula costo estimado de una llamada"""
    pricing = PRICING.get(model, PRICING["gpt-4o"])
    cost = (
        input_tokens * pricing["input"] +
        output_tokens * pricing["output"]
    )
    return cost

# Ejemplo
cost = estimate_cost(1000, 500, "gpt-4o")
print(f"Costo estimado: ${cost:.4f}")
```

### Optimizaciones para Reducir Costos

```python
# 1. Usar modelos más baratos cuando sea posible
def choose_model_by_complexity(task_complexity: str) -> str:
    """Selecciona modelo según complejidad"""
    return {
        "simple": "gpt-3.5-turbo",    # Tareas simples
        "medium": "gpt-4o",            # Balanceado
        "complex": "gpt-4",            # Razonamiento complejo
    }[task_complexity]

# 2. Cache de respuestas idénticas
from functools import lru_cache
import hashlib

def cache_key(messages: List[Dict]) -> str:
    """Genera cache key de mensajes"""
    content = json.dumps(messages, sort_keys=True)
    return hashlib.sha256(content.encode()).hexdigest()

cached_responses = {}

def get_completion_cached(messages: List[Dict], model: str) -> str:
    """Completions con cache"""
    key = cache_key(messages)

    if key in cached_responses:
        print("✓ Cache hit")
        return cached_responses[key]

    response = client.chat.completions.create(
        model=model,
        messages=messages
    )
    result = response.choices[0].message.content
    cached_responses[key] = result
    return result

# 3. Limitar max_tokens cuando sea posible
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Di 'sí' o 'no'"}],
    max_tokens=5,  # Limita respuesta corta
)

# 4. Batch processing para múltiples tareas
def process_batch(prompts: List[str]) -> List[str]:
    """Procesa múltiples prompts en paralelo"""
    import concurrent.futures

    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        futures = [
            executor.submit(get_completion, prompt)
            for prompt in prompts
        ]
        return [f.result() for f in futures]
```

---

## Testing de LLMs

### Unit Tests con Mocks

```python
from unittest.mock import Mock, patch
import pytest

def test_llm_completion():
    """Test con mock de respuesta"""
    mock_client = Mock()
    mock_response = Mock()
    mock_response.choices[0].message.content = "Mocked response"
    mock_client.chat.completions.create.return_value = mock_response

    # Tu función que usa el cliente
    result = your_function_using_llm(mock_client)

    assert result == "Mocked response"
    mock_client.chat.completions.create.assert_called_once()

@patch('openai.OpenAI')
def test_with_patch(mock_openai):
    """Test con patch del cliente completo"""
    mock_instance = Mock()
    mock_openai.return_value = mock_instance

    # Tu código aquí
    client = OpenAI()
    # ...

    assert mock_openai.called
```

### E2E Tests (con modelos reales)

```python
@pytest.mark.slow  # Marca tests lentos/costosos
def test_actual_llm_call():
    """Test con llamada real (solo en CI/staging)"""
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",  # Modelo más barato para tests
        messages=[
            {"role": "user", "content": "Di 'test ok'"}
        ],
        max_tokens=10,
    )

    result = response.choices[0].message.content
    assert "test" in result.lower() or "ok" in result.lower()
```

---

## Seguridad y Buenas Prácticas

### 1. NUNCA expongas API keys

```python
# ❌ MAL: Hardcoded
client = OpenAI(api_key="sk-...")

# ✅ BIEN: Variables de entorno
import os
from dotenv import load_dotenv

load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# .gitignore
# .env
# *.key
```

### 2. Validación de inputs

```python
def sanitize_user_input(user_input: str) -> str:
    """Limpia input del usuario"""
    # Limitar longitud
    MAX_LENGTH = 2000
    user_input = user_input[:MAX_LENGTH]

    # Remover contenido peligroso (opcional)
    # user_input = user_input.replace("ignore previous instructions", "")

    return user_input.strip()

# Uso
user_prompt = sanitize_user_input(request.data["message"])
```

### 3. Rate Limiting

```python
from datetime import datetime, timedelta
from collections import defaultdict

class RateLimiter:
    def __init__(self, max_requests: int, time_window: int):
        self.max_requests = max_requests
        self.time_window = time_window  # segundos
        self.requests = defaultdict(list)

    def allow_request(self, user_id: str) -> bool:
        now = datetime.now()
        cutoff = now - timedelta(seconds=self.time_window)

        # Limpiar requests antiguos
        self.requests[user_id] = [
            req_time for req_time in self.requests[user_id]
            if req_time > cutoff
        ]

        # Verificar límite
        if len(self.requests[user_id]) >= self.max_requests:
            return False

        self.requests[user_id].append(now)
        return True

# Uso
limiter = RateLimiter(max_requests=10, time_window=60)  # 10 req/min

if not limiter.allow_request(user_id):
    raise Exception("Rate limit exceeded")
```

---

## Recursos y Referencias

### Documentación Oficial
- **OpenAI**: https://platform.openai.com/docs
- **Anthropic (Claude)**: https://docs.anthropic.com
- **Google (Gemini)**: https://ai.google.dev/docs

### Herramientas Útiles
- **LangChain**: Framework para apps LLM (Python/JS)
- **LlamaIndex**: RAG y búsqueda semántica
- **Tiktoken**: Contador de tokens (OpenAI)
- **Prompt Engineering Guide**: https://www.promptingguide.ai

### Modelos Open Source
- **Ollama**: Ejecutar Llama, Mistral, etc. localmente
- **Hugging Face**: Hub de modelos pre-entrenados

---

## Auto-Mantenimiento

Este skill se auto-actualiza usando Context7:

```python
# Claude Code puede actualizar este skill con:
mcp__context7__resolve_library_id(libraryName="OpenAI")
mcp__context7__query_docs(
    libraryId="/openai/openai-python",
    query="latest API changes 2026"
)
```

**Última revisión**: 2026-02-05
**Próxima revisión sugerida**: 2026-05-05 (cada 3 meses)

---

*Skill mantenido por Claude Code según preferencias de jgmoreu*
*Ver: ~/.claude/CLAUDE.md para más información del sistema de skills*
