# Pipeline multiagente para OpenCode

Plantilla reutilizable: cuatro agentes especializados que se ejecutan en cadena, cada uno con el mejor modelo **100 % gratuito** de las APIs de Groq, OpenRouter, Gemini y NVIDIA NIM. Todo (agentes, comandos y artefactos) está en **español**.

**Este repositorio no contiene ninguna API key.** El asistente de instalación pide las claves propias de quien lo use y las mantiene únicamente en el entorno del proceso.

## Modelos seleccionados

| Etapa | Agente | Proveedor | Modelo gratuito | Por qué se eligió |
| --- | --- | --- | --- | --- |
| 1 | `planificador` | **OpenRouter** | `nvidia/nemotron-3-ultra-550b-a55b:free` | Modelo de razonamiento y orquestación: 550 B totales / 55 B activos, 1 M de contexto, `$0/M`. Pensado para flujos agénticos de varios pasos y planificación. |
| 2 | `arquitecto` | **Gemini** | `gemini-3.5-flash-lite` | 1 M de contexto, tool calling y *thinking*. Recomendado por Google para tareas de subagente. Consulta tus límites del plan gratuito en AI Studio (varían por proyecto/región). |
| 3 | `constructor` | **Groq** | `openai/gpt-oss-120b` | ~500 tok/s, 131 K de contexto, soporte de herramientas y plan gratuito (30 req/min, 1.000 req/día). Ideal para escribir código rápido. |
| 4 | `auditor` | **NVIDIA NIM** | `nvidia/nemotron-3.5-lightning-30b-a3b` | Modelo ágil de razonamiento y tareas agénticas, 1 M de contexto y tool calling. Responde en ~1 s, frente a los >90 s del modelo grande de DeepSeek en el plan gratuito. |

El `director` (agente primario) usa el modelo de OpenRouter por defecto y solo coordina; no ejecuta las etapas.

> Los catálogos gratuitos cambian con frecuencia. Si un modelo deja de estar disponible, ejecuta `/models` y ajusta el `modelID` en `.opencode/opencode.jsonc`.

## Instalación

### 1. Clonar

```bash
git clone https://github.com/jhonni-png/opencode-pipeline.git
cd opencode-pipeline
```

### 2. Ejecutar el asistente de credenciales

Te preguntará por tus cuatro claves con entrada oculta, las exportará solo en memoria y arrancará OpenCode.

**Windows (PowerShell):**

```powershell
.\setup.ps1
```

Si PowerShell bloquea la ejecución de scripts:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

**macOS / Linux / Git Bash:**

```bash
chmod +x setup.sh && ./setup.sh
```

Para solo cargar las claves en la sesión actual sin arrancar OpenCode: `.\setup.ps1 -SkipLaunch` o `./setup.sh --no-launch`. Si una variable ya está configurada, el asistente pregunta si deseas conservarla.

Obtén tus claves gratis aquí: [Groq](https://console.groq.com/keys) · [OpenRouter](https://openrouter.ai/keys) · [Google AI Studio](https://aistudio.google.com/apikey) · [NVIDIA NIM](https://build.nvidia.com/).

Para NVIDIA se aceptan ambos nombres, `NVIDIA_NIM_API_KEY` y `NVIDIA_API_KEY`; el asistente rellena los dos con el mismo valor.

### 3. (Opcional) Instalar de forma global

Así el pipeline queda disponible desde cualquier directorio. Hazlo **después** de cargar las claves.

**Windows (PowerShell):**

```powershell
$dst = Join-Path $HOME ".config\opencode"
New-Item -ItemType Directory -Force -Path "$dst\agents","$dst\commands" | Out-Null
Copy-Item .\.opencode\opencode.jsonc "$dst\opencode.jsonc" -Force
Copy-Item .\.opencode\agents\*.md "$dst\agents\" -Force
Copy-Item .\.opencode\commands\*.md "$dst\commands\" -Force
```

**macOS / Linux:**

```bash
dst="$HOME/.config/opencode"; mkdir -p "$dst/agents" "$dst/commands"
cp .opencode/opencode.jsonc "$dst/opencode.jsonc"
cp .opencode/agents/*.md "$dst/agents/"
cp .opencode/commands/*.md "$dst/commands/"
```

## Seguridad de credenciales

- No hay claves en los archivos: la configuración usa `env: [...]` y sustituciones `{env:VAR}`.
- La resolución ocurre en memoria, dentro del proceso de OpenCode. Nada se escribe en disco ni se envía a ningún servicio.
- `.gitignore` bloquea `.env`, `*.key`, `*.pem` y carpetas de secretos. `.env.example` solo lista los nombres de las variables, sin valores.
- No se usa `setx`: persistiría las claves en texto plano en el registro de Windows.
- Para comprobar qué variables hay, sin mostrar sus valores:

```powershell
Get-ChildItem env: | Where-Object Name -match 'API_KEY' | Select-Object Name
```

```bash
env | grep -E 'API_KEY=' | cut -d= -f1
```

## Uso

Dentro de OpenCode, verifica los modelos disponibles:

```text
/models
```

Deben aparecer `groq/gpt-oss-120b`, `openrouter/nemotron-ultra-free`, `gemini/flash-lite` y `nim/nemotron-3.5-lightning`. Luego lanza el pipeline:

```text
/pipeline Crea una API REST en Node para gestionar tareas con SQLite
```

También puedes pedírselo en lenguaje natural al agente `director`; el comando solo fija el agente y el formato de la instrucción.

## Flujo

```
/pipeline <tarea>
   │
   ├─ 1. planificador  →  .opencode/pipeline/<slug>/01-plan.md
   ├─ 2. arquitecto    →  .opencode/pipeline/<slug>/02-arquitectura.md
   ├─ 3. constructor   →  .opencode/pipeline/<slug>/03-construccion.md
   └─ 4. auditor       →  .opencode/pipeline/<slug>/04-auditoria.md
```

Cada etapa espera el informe de la anterior y verifica su artefacto antes de continuar. Si una etapa falla, el pipeline se detiene y explica el error.

## Estructura

```text
setup.ps1                 # asistente de credenciales para Windows
setup.sh                  # asistente de credenciales para macOS/Linux
.opencode/
├── opencode.jsonc        # proveedores, modelos y agente por defecto
├── agents/
│   ├── director.md       # orquestador (primary)
│   ├── planificador.md   # etapa 1
│   ├── arquitecto.md     # etapa 2
│   ├── constructor.md    # etapa 3
│   └── auditor.md        # etapa 4
└── commands/
    └── pipeline.md       # comando /pipeline
.env.example              # solo nombres de variables
.gitignore                # bloquea .env y secretos
```
