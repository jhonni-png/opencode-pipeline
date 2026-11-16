# Pipeline multiagente para OpenCode

Cuatro agentes especializados que se ejecutan en cadena, cada uno con el mejor modelo **100 % gratuito** disponible en las cuatro APIs solicitadas. Todo el contenido (agentes, comandos y artefactos) está en **español**.

Repositorio: **jhonni-png/opencode-pipeline** (privado). Cuenta de GitHub conectada mediante `gh` CLI (`jhonni-png`).

## Roles y modelos seleccionados

| Etapa | Agente | Proveedor | Modelo | Por qué se eligió |
| --- | --- | --- | --- | --- |
| 1 | `planificador` | **OpenRouter** | `nvidia/nemotron-3-ultra-550b-a55b:free` | Modelo de razonamiento y orquestación: 550 B totales / 55 B activos, 1 M de contexto, `$0/M`. Pensado para flujos agénticos de varios pasos y planificación. |
| 2 | `arquitecto` | **Gemini** | `gemini-3.5-flash-lite` | 1 M de contexto, tool calling y *thinking*. Recomendado por Google para tareas de subagente; el plan gratuito cubre este uso. |
| 3 | `constructor` | **Groq** | `openai/gpt-oss-120b` | ~500 tok/s, 131 K de contexto, soporte de herramientas y plan gratuito (30 req/min, 1.000 req/día). Ideal para escribir código rápido. |
| 4 | `auditor` | **NVIDIA NIM** | `deepseek-ai/deepseek-v4.1-flash` | Razonamiento profundo, 1 M de contexto, function calling. Excelente para revisión crítica (DeepSWE 74.2, Terminal-Bench 2.1 90.6). |

El `director` (agente primario) usa el mismo modelo de OpenRouter por defecto y solo coordina; no hace el trabajo de las etapas.

> Los catálogos gratuitos cambian con frecuencia. Si un modelo deja de estar disponible, revisa `/models` dentro de OpenCode y ajusta el `modelID` en `.opencode/opencode.jsonc`.

## Flujo

```
/pipeline <tarea>
   │
   ├─ 1. planificador  →  .opencode/pipeline/<slug>/01-plan.md
   ├─ 2. arquitecto    →  .opencode/pipeline/<slug>/02-arquitectura.md
   ├─ 3. constructor   →  .opencode/pipeline/<slug>/03-construccion.md
   └─ 4. auditor       →  .opencode/pipeline/<slug>/04-auditoria.md
```

Cada etapa espera el informe de la anterior y verifica su artefacto antes de continuar. Si una falla, el pipeline se detiene.

## Credenciales: solo variables de entorno

**No hay ninguna clave guardada en archivos.** La configuración usa `{env:VAR}` y la lista `env`, de modo que OpenCode lee las credenciales del proceso. `.env.example` contiene únicamente los nombres de las variables.

Obtén las claves gratis en: [Groq](https://console.groq.com/keys) · [OpenRouter](https://openrouter.ai/keys) · [Google AI Studio](https://aistudio.google.com/apikey) · [NVIDIA NIM](https://build.nvidia.com/).

### Inyección segura desde la terminal (PowerShell)

Pega esto en la **misma sesión** en la que arrancarás OpenCode. `Read-Host -AsSecureString` evita que la clave quede visible en pantalla ni en el historial:

```powershell
function Set-SecretEnv {
    param([string]$Name, [string]$Prompt)
    $secure = Read-Host $Prompt -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        [System.Environment]::SetEnvironmentVariable(
            $Name,
            [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr),
            'Process'
        )
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

Set-SecretEnv GROQ_API_KEY        "API key de Groq"
Set-SecretEnv OPENROUTER_API_KEY  "API key de OpenRouter"
Set-SecretEnv GEMINI_API_KEY      "API key de Gemini"
Set-SecretEnv NVIDIA_API_KEY      "API key de NVIDIA NIM"

# --standalone hace que la TUI y el servidor compartan este mismo entorno.
opencode --standalone
```

En PowerShell 7 también puedes usar `$env:GROQ_API_KEY = Read-Host "Groq" -MaskInput`.

Si prefieres el servicio en segundo plano, reinícialo desde una sesión que ya tenga las variables exportadas (`opencode service restart`). Evita `opencode service set env ...` si no quieres persistir valores en la configuración del servicio.

### Comprobación rápida

Dentro de OpenCode, ejecuta `/models`: deben aparecer `groq/gpt-oss-120b`, `openrouter/nemotron-ultra-free`, `gemini/flash-lite` y `nim/deepseek-v4.1-flash`.

## Uso

```text
/pipeline Crea una API REST en Node para gestionar tareas con SQLite
```

También puedes abrir OpenCode y pedírselo al agente `director` en lenguaje natural; el comando solo fija el agente y el formato de la instrucción.

## Estructura

```text
.opencode/
├── opencode.jsonc            # proveedores, modelos y agente por defecto
├── agents/
│   ├── director.md           # orquestador (primary)
│   ├── planificador.md       # etapa 1
│   ├── arquitecto.md         # etapa 2
│   ├── constructor.md        # etapa 3
│   └── auditor.md            # etapa 4
└── commands/
    └── pipeline.md           # comando /pipeline
.env.example                  # solo nombres de variables
.gitignore                    # bloquea .env y secretos
```

La misma configuración se instala de forma global en `~/.config/opencode/`, así que el pipeline está disponible desde cualquier directorio.
