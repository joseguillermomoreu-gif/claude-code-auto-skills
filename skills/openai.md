# OpenAI API - Patrones Python

> **SDK**: openai-python (oficial)
> **Última actualización**: 2026-02-04
> **Versión SDK**: 1.x

## Setup Inicial

```python
# pyproject.toml
[tool.poetry.dependencies]
openai = "^1.50.0"
python-dotenv = "^1.0.0"

# .env
OPENAI_API_KEY=sk-...
OPENAI_ORG_ID=org-...  # Opcional
```

```python
# src/config/openai_client.py
from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()

client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    organization=os.getenv("OPENAI_ORG_ID"),  # Opcional
)
```

## Chat Completions (Patrón Base)

```python
from openai import OpenAI
from typing import Optional

def ask_gpt(
    prompt: str,
    model: str = "gpt-4o",
    temperature: float = 0.7,
    max_tokens: Optional[int] = None,
    system_prompt: str = "You are a helpful assistant."
) -> str:
    """
    Wrapper básico para chat completions.
    """
    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ],
            temperature=temperature,
            max_tokens=max_tokens
        )
        return response.choices[0].message.content or ""

    except Exception as e:
        raise OpenAIError(f"API call failed: {str(e)}")
```

## Streaming Responses

```python
from typing import Generator

def ask_gpt_stream(
    prompt: str,
    model: str = "gpt-4o"
) -> Generator[str, None, None]:
    """
    Streaming para UIs interactivas.
    """
    stream = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        stream=True
    )

    for chunk in stream:
        if chunk.choices[0].delta.content:
            yield chunk.choices[0].delta.content

# Uso:
for token in ask_gpt_stream("Explain Python decorators"):
    print(token, end="", flush=True)
```

## Error Handling (Robusto)

```python
from openai import (
    OpenAIError,
    RateLimitError,
    APIConnectionError,
    AuthenticationError
)
import time
from typing import Callable, TypeVar

T = TypeVar('T')

def retry_with_backoff(
    max_retries: int = 3,
    initial_delay: float = 1.0
):
    """
    Decorator para retry con exponential backoff.
    """
    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        def wrapper(*args, **kwargs) -> T:
            delay = initial_delay

            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)

                except RateLimitError:
                    if attempt == max_retries - 1:
                        raise
                    print(f"Rate limited. Waiting {delay}s...")
                    time.sleep(delay)
                    delay *= 2  # Exponential backoff

                except APIConnectionError:
                    if attempt == max_retries - 1:
                        raise
                    print(f"Connection error. Retrying in {delay}s...")
                    time.sleep(delay)

                except AuthenticationError:
                    raise  # No retry en auth errors

                except OpenAIError as e:
                    print(f"OpenAI error: {e}")
                    raise

        return wrapper
    return decorator

@retry_with_backoff(max_retries=3)
def safe_ask_gpt(prompt: str) -> str:
    return ask_gpt(prompt)
```

## Embeddings (Búsqueda Semántica)

```python
import numpy as np
from typing import List

def get_embedding(
    text: str,
    model: str = "text-embedding-3-small"
) -> List[float]:
    """
    Genera embedding para texto.
    """
    response = client.embeddings.create(
        model=model,
        input=text
    )
    return response.data[0].embedding

def cosine_similarity(vec1: List[float], vec2: List[float]) -> float:
    """
    Calcula similitud entre embeddings.
    """
    a = np.array(vec1)
    b = np.array(vec2)
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

# Ejemplo: búsqueda semántica
docs = [
    "Python es un lenguaje de programación",
    "Symfony es un framework PHP",
    "Machine learning usa algoritmos"
]

query = "programación backend"
query_emb = get_embedding(query)

for doc in docs:
    doc_emb = get_embedding(doc)
    similarity = cosine_similarity(query_emb, doc_emb)
    print(f"{doc}: {similarity:.3f}")
```

## Function Calling (Tool Use)

```python
from typing import List, Dict, Any
import json

tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City name"
                    }
                },
                "required": ["location"]
            }
        }
    }
]

def get_weather(location: str) -> Dict[str, Any]:
    """Implementación real de la función"""
    # En producción, llamarías a una API real
    return {"temp": 22, "condition": "sunny", "location": location}

def ask_with_tools(prompt: str) -> str:
    """Chat con function calling"""
    messages = [{"role": "user", "content": prompt}]

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=messages,
        tools=tools
    )

    message = response.choices[0].message

    # Si el modelo quiere usar una función
    if message.tool_calls:
        tool_call = message.tool_calls[0]
        function_name = tool_call.function.name
        arguments = json.loads(tool_call.function.arguments)

        # Ejecutar función
        if function_name == "get_weather":
            result = get_weather(**arguments)

            # Enviar resultado de vuelta
            messages.append(message)
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": json.dumps(result)
            })

            final_response = client.chat.completions.create(
                model="gpt-4o",
                messages=messages
            )
            return final_response.choices[0].message.content or ""

    return message.content or ""
```

## Conversation History

```python
from typing import List, Dict

class ConversationManager:
    """Maneja el historial de conversación"""

    def __init__(self, system_prompt: str, max_messages: int = 10):
        self.messages: List[Dict[str, str]] = [
            {"role": "system", "content": system_prompt}
        ]
        self.max_messages = max_messages

    def add_user_message(self, content: str) -> None:
        self.messages.append({"role": "user", "content": content})
        self._truncate_if_needed()

    def add_assistant_message(self, content: str) -> None:
        self.messages.append({"role": "assistant", "content": content})

    def get_response(self, model: str = "gpt-4o") -> str:
        response = client.chat.completions.create(
            model=model,
            messages=self.messages
        )

        content = response.choices[0].message.content or ""
        self.add_assistant_message(content)
        return content

    def _truncate_if_needed(self) -> None:
        """Mantiene solo los últimos N mensajes + system prompt"""
        if len(self.messages) > self.max_messages:
            # Preserva system message + últimos N mensajes
            self.messages = [self.messages[0]] + self.messages[-(self.max_messages-1):]

# Uso:
chat = ConversationManager("You are a helpful Python tutor")
chat.add_user_message("What are decorators?")
response = chat.get_response()
print(response)

chat.add_user_message("Can you give me an example?")
response = chat.get_response()
print(response)
```

## Best Practices

### 1. Costos y Monitoreo

```python
from dataclasses import dataclass

@dataclass
class UsageStats:
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int

    @property
    def estimated_cost(self) -> float:
        # Precios aproximados para gpt-4o (verificar precios actuales)
        input_cost = (self.prompt_tokens / 1000) * 0.005
        output_cost = (self.completion_tokens / 1000) * 0.015
        return input_cost + output_cost

def ask_gpt_with_stats(prompt: str) -> tuple[str, UsageStats]:
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}]
    )

    usage = response.usage
    stats = UsageStats(
        prompt_tokens=usage.prompt_tokens,
        completion_tokens=usage.completion_tokens,
        total_tokens=usage.total_tokens
    )

    content = response.choices[0].message.content or ""
    return content, stats
```

### 2. Prompt Templates

```python
from string import Template

SYSTEM_PROMPT = """
You are an expert Python developer.
Follow these rules:
- Write type hints
- Use PEP 8 conventions
- Prefer dataclasses over dicts
"""

USER_PROMPT_TEMPLATE = Template("""
Refactor this code:
\`\`\`python
$code
\`\`\`

Requirements: $requirements
""")

def refactor_code(code: str, requirements: str) -> str:
    prompt = USER_PROMPT_TEMPLATE.substitute(
        code=code,
        requirements=requirements
    )

    return ask_gpt(prompt, system_prompt=SYSTEM_PROMPT)
```

### 3. Rate Limiting

```python
from datetime import datetime, timedelta
from collections import deque

class RateLimiter:
    """Simple rate limiter"""

    def __init__(self, max_requests: int, time_window: timedelta):
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests: deque = deque()

    def can_make_request(self) -> bool:
        now = datetime.now()
        cutoff = now - self.time_window

        # Remove old requests
        while self.requests and self.requests[0] < cutoff:
            self.requests.popleft()

        return len(self.requests) < self.max_requests

    def record_request(self) -> None:
        self.requests.append(datetime.now())

# Uso:
limiter = RateLimiter(max_requests=60, time_window=timedelta(minutes=1))

def rate_limited_ask_gpt(prompt: str) -> str:
    if not limiter.can_make_request():
        raise Exception("Rate limit exceeded")

    limiter.record_request()
    return ask_gpt(prompt)
```

---

## 🔧 Mantenimiento de este Skill

### Para Claude Code:
**Actualiza cuando**:
- Detectes que uso una versión más nueva del SDK
- OpenAI lance nuevos modelos (gpt-5, etc.)
- Cambien precios o límites de rate
- Encuentres mejores patrones de error handling

**Preserva siempre**:
- Ejemplos con type hints
- Patrones de retry/backoff
- Código funcional y testeable

**Usa Context7**:
```python
resolve-library-id: "openai/openai-python"
query-docs: "latest openai python sdk features 2026"
```

**Notifica cuando actualices**:
```
📝 Actualizado skills/openai.md:
- Añadida sección de Batch API (nueva en 1.50.0)
- Actualizado modelo recomendado: gpt-4o → gpt-4o-2026-02
- Preservados tus patrones de error handling
```
