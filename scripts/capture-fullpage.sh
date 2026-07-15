#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/fullpage-png"
DEFAULT_URL="${FULLPAGE_URL:-http://127.0.0.1:4321/}"
DEFAULT_OUTPUT="${FULLPAGE_OUTPUT:-$ROOT_DIR/assets/readme/home-desktop.png}"
DEFAULT_WIDTH="${FULLPAGE_WIDTH:-1600}"
CHROMIUM_BIN="${FULLPAGE_CHROMIUM:-$(command -v chromium || true)}"

usage() {
  cat <<'EOF'
Uso:
  ./scripts/capture-fullpage.sh [opciones]

Opciones:
  -u, --url URL           URL a capturar (default: http://127.0.0.1:4321/)
  -o, --output FILE       Archivo de salida (default: ./assets/readme/home-desktop.png)
  -w, --width WIDTH       Ancho del viewport (default: 1600)
  -d, --delay MS          Delay extra antes de capturar (default: 500)
  -h, --help              Mostrar esta ayuda
EOF
}

URL="$DEFAULT_URL"
OUTPUT="$DEFAULT_OUTPUT"
WIDTH="$DEFAULT_WIDTH"
DELAY="500"


while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--url)
      URL="$2"
      shift 2
      ;;
    -o|--output)
      OUTPUT="$2"
      shift 2
      ;;
    -w|--width)
      WIDTH="$2"
      shift 2
      ;;
    -d|--delay)
      DELAY="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Opción desconocida: $1"
      usage
      exit 1
      ;;
  esac

done

# Mantén rutas absolutas si viene por argumento
if [[ "$OUTPUT" != /* ]]; then
  OUTPUT="$ROOT_DIR/$OUTPUT"
fi

if [[ -z "$CHROMIUM_BIN" ]]; then
  echo "❌ No se encontró Chromium del sistema."
  echo "Define FULLPAGE_CHROMIUM o instala chromium."
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

if command -v uv >/dev/null 2>&1; then
  (cd "$PROJECT_DIR" && uv run --project . main.py \
    "$URL" \
    --chromium "$CHROMIUM_BIN" \
    -o "$OUTPUT" \
    --width "$WIDTH" \
    --delay "$DELAY")
else
  # Nix fallback (sin dependencia previa de uv en PATH)
  (cd "$PROJECT_DIR" && nix run nixpkgs#uv -- run --project . main.py \
    "$URL" \
    --chromium "$CHROMIUM_BIN" \
    -o "$OUTPUT" \
    --width "$WIDTH" \
    --delay "$DELAY")
fi
