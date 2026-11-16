#!/usr/bin/env bash
# Asistente de configuracion para macOS / Linux (y Git Bash en Windows).
# Pide las API keys de cada usuario y las exporta SOLO en este proceso.
# Nunca escribe claves en disco ni en ficheros de perfil.
#
# Uso:
#   chmod +x setup.sh && ./setup.sh      # pedir claves y arrancar OpenCode
#   ./setup.sh --no-launch               # solo cargar claves en la sesion actual

set -euo pipefail

KEYS=(GROQ_API_KEY OPENROUTER_API_KEY GEMINI_API_KEY NVIDIA_API_KEY)

echo "Configuracion de credenciales del pipeline multiagente"
echo "Las claves se piden de forma oculta y solo viven en memoria."
echo

for key in "${KEYS[@]}"; do
  actual="${!key:-}"
  if [[ -n "$actual" ]]; then
    read -r -p "$key ya esta configurado. Reemplazarlo? [s/N] " answer
    if [[ ! "$answer" =~ ^[sS] ]]; then
      echo "  Se mantiene el valor actual."
      continue
    fi
  fi

  read -r -s -p "$key (oculto): " value
  echo
  if [[ -n "$value" ]]; then
    export "$key=$value"
    # NVIDIA publica su clave como NVIDIA_API_KEY; aceptamos ambos nombres.
    if [[ "$key" == "NVIDIA_NIM_API_KEY" ]]; then
      export NVIDIA_API_KEY="$value"
    fi
    echo "  OK"
  else
    echo "  Vacio: no se cambia nada."
  fi
done

unset value actual answer 2>/dev/null || true
echo
echo "Claves cargadas en esta sesion. No se guardan en archivos."

if [[ "${1:-}" != "--no-launch" ]]; then
  echo "Arrancando OpenCode..."
  exec opencode --standalone
fi
