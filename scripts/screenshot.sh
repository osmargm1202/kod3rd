#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PORT="${SCREENSHOT_PORT:-4321}"
HOST="${SCREENSHOT_HOST:-127.0.0.1}"
URL="http://${HOST}:${PORT}/"
OUT_DIR="$ROOT_DIR/assets/readme"
CHROMIUM_BIN="${SCREENSHOT_CHROMIUM:-chromium}"

mkdir -p "$OUT_DIR"

if ! command -v "$CHROMIUM_BIN" >/dev/null 2>&1; then
  echo "❌ No se encontró el binario '$CHROMIUM_BIN'."
  echo "Instala Chromium en NixOS (ej: nix-shell -p chromium --run 'chromium --version')."
  exit 1
fi

wait_for_server() {
  local attempts=40
  local i=1

  while (( i <= attempts )); do
    if curl -fsS "${URL}" >/dev/null 2>&1; then
      echo "✅ Proyecto disponible en ${URL}"
      return 0
    fi
    echo "Esperando servidor en ${URL} (intento ${i}/${attempts})"
    sleep 1
    ((i++))
  done

  echo "❌ Timeout: no pude alcanzar ${URL}."
  echo "Arranca el proyecto con: npm run dev -- --host ${HOST} --port ${PORT}"
  exit 1
}

if ! curl -fsS "$URL" >/dev/null 2>&1; then
  echo "⚠️ No hay servidor corriendo en ${URL}."
  echo "Iniciando dev server temporalmente para capturas..."

  npm run dev -- --host "$HOST" --port "$PORT" >"$OUT_DIR/.screenshot-dev.log" 2>&1 &
  DEV_PID=$!

  cleanup() {
    if [[ -n "${DEV_PID:-}" ]] && kill -0 "$DEV_PID" 2>/dev/null; then
      kill "$DEV_PID"
      wait "$DEV_PID" 2>/dev/null || true
    fi
  }
  trap cleanup EXIT

  wait_for_server
else
  echo "✅ Servidor ya activo en ${URL}, usando instancia existente"
fi

capture() {
  local label="$1"
  local w="$2"
  local h="$3"
  local outfile="$OUT_DIR/${label}.png"

  "$CHROMIUM_BIN" \
    --headless \
    --no-sandbox \
    --disable-gpu \
    --hide-scrollbars \
    --window-size="${w},${h}" \
    --screenshot="$outfile" \
    --virtual-time-budget=8000 \
    "$URL"

  echo "🖼  Guardado: $outfile"
}

capture "home-desktop" 1600 2600
capture "home-tablet"  1024 1800
capture "home-mobile"  390  2600

echo "✅ Capturas completas en: $OUT_DIR"
