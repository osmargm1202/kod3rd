#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PORT="${SCREENSHOT_PORT:-4321}"
HOST="${SCREENSHOT_HOST:-127.0.0.1}"
URL="http://${HOST}:${PORT}/"
OUT_DIR="$ROOT_DIR/assets/readme"
CHROMIUM_BIN="${SCREENSHOT_CHROMIUM:-chromium}"
DESKTOP_HEIGHT="${SCREENSHOT_DESKTOP_HEIGHT:-14000}"
TABLET_HEIGHT="${SCREENSHOT_TABLET_HEIGHT:-14000}"
MOBILE_HEIGHT="${SCREENSHOT_MOBILE_HEIGHT:-14000}"
USE_PLAYWRIGHT="${SCREENSHOT_USE_PLAYWRIGHT:-0}"

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

capture_chromium() {
  local label="$1"
  local w="$2"
  local h="$3"
  local outfile="$OUT_DIR/${label}.png"

  "$CHROMIUM_BIN" \
    --headless \
    --no-sandbox \
    --disable-gpu \
    --disable-lcd-text \
    --disable-font-subpixel-positioning \
    --hide-scrollbars \
    --window-size="${w},${h}" \
    --screenshot="$outfile" \
    --virtual-time-budget=9000 \
    "$URL"

  echo "🖼  Guardado: $outfile"
}

capture_playwright() {
  local label="$1"
  local w="$2"
  local outfile="$OUT_DIR/${label}.png"

  # 1) Prefer local fullpage-png tool (Python + Playwright) to force full-page real
  local fullpage_project="$ROOT_DIR/fullpage-png"

  if command -v uv >/dev/null 2>&1 && [ -f "$fullpage_project/pyproject.toml" ]; then
    local chromium_arg=()

    if command -v "$CHROMIUM_BIN" >/dev/null 2>&1; then
      chromium_arg+=(--chromium "$CHROMIUM_BIN")
    fi

    if (cd "$fullpage_project" && uv run fullpage-png "$URL" --width "$w" --output "$outfile" "${chromium_arg[@]}"); then
      echo "🖼  Guardado: $outfile"
      return
    fi
  fi

  # 2) Fallback to Playwright CLI
  if command -v playwright >/dev/null 2>&1; then
    if playwright screenshot "$URL" "$outfile" --full-page; then
      echo "🖼  Guardado: $outfile"
      return
    fi
  fi

  if [ -n "${SCREENSHOT_PLAYWRIGHT_CLI:-}" ] && command -v npx >/dev/null 2>&1; then
    if npx --yes playwright screenshot "$URL" "$outfile" --full-page; then
      echo "🖼  Guardado: $outfile"
      return
    fi
  fi

  echo "⚠️  Playwright no está disponible; usando Chromium con height alto." >&2
  return 1
}

capture() {
  local label="$1"
  local w="$2"
  local h="$3"

  if [ "$USE_PLAYWRIGHT" = "1" ]; then
    if capture_playwright "$label" "$w"; then
      return
    fi
  fi

  capture_chromium "$label" "$w" "$h"
}

capture "home-desktop" 1600 "$DESKTOP_HEIGHT"
capture "home-tablet"  1024 "$TABLET_HEIGHT"
capture "home-mobile"  390  "$MOBILE_HEIGHT"

echo "✅ Capturas completas en: $OUT_DIR"
