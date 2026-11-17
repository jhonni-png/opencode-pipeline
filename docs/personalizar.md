# Personalizar el pipeline

Todo vive en `.opencode/`. Estas son las tres cosas que probablemente quieras cambiar.

## Cambiar el modelo de un agente

Cada agente declara su modelo en la cabecera de su archivo, con el formato `proveedor/modelo`:

```yaml
# .opencode/agents/constructor.md
---
description: Etapa 3 - implementa el código siguiendo el plan y la arquitectura aprobados.
mode: subagent
model: groq/gpt-oss-120b
---
```

El `proveedor/modelo` tiene que existir en `.opencode/opencode.jsonc`, dentro de `providers.<proveedor>.models.<modelo>`. Por ejemplo, `groq/gpt-oss-120b` apunta a `providers.groq.models["gpt-oss-120b"]`, y el `modelID` de esa entrada es el nombre real que envía la API.

Para usar otro modelo del mismo proveedor:

1. Añade una entrada en `providers.<proveedor>.models` de `opencode.jsonc` (copia una existente y cambia `modelID`, `name` y los límites).
2. Cambia la línea `model:` del agente.
3. Dentro de OpenCode, ejecuta `/models` para comprobar que aparece.

> Los catálogos gratuitos cambian con frecuencia. Si un modelo desaparece, la etapa falla y el pipeline se detiene explicando el error; ajusta el `modelID` y vuelve a lanzar.

## Cambiar de proveedor

Si el proveedor nuevo es compatible con la API de OpenAI, copia el bloque de `groq` o `gemini` en `opencode.jsonc`, cambia `baseURL`, el nombre de la variable de entorno en `env` y en `apiKey`, y añade esa variable a `.env.example` y a los scripts de `scripts/`. **Nunca escribas una clave dentro de `opencode.jsonc`**: solo la sustitución `{env:NOMBRE}`.

## Añadir un agente a la cadena

1. Crea `.opencode/agents/<nombre>.md` con `mode: subagent`, su `model:` y sus instrucciones (copia uno existente como base).
2. En `.opencode/agents/director.md`, añade en `permissions` una entrada que permita ese subagente:

   ```yaml
   - action: subagent
     resource: <nombre>
     effect: allow
   ```

3. Explica en el cuerpo de `director.md` y en `.opencode/commands/pipeline.md` en qué punto de la cadena entra y qué artefacto produce (`.opencode/pipeline/<slug>/NN-<nombre>.md`).

## Probar un cambio

```text
/models
/pipeline Crea un script en Python que renombre archivos por fecha
```

Revisa que se creen los cuatro artefactos en `.opencode/pipeline/<slug>/`.
