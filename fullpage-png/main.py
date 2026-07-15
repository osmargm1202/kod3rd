from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path
from urllib.parse import urlparse
from shutil import which

from playwright.sync_api import Error, TimeoutError, sync_playwright


def normalize_source(source: str) -> str:
    parsed = urlparse(source)

    if parsed.scheme in {"http", "https", "file"}:
        return source

    path = Path(source).expanduser().resolve()

    if not path.exists():
        raise FileNotFoundError(f"No existe el archivo: {path}")

    return path.as_uri()


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Genera un PNG de página completa usando Chromium."
    )

    parser.add_argument(
        "source",
        help="URL o archivo HTML local.",
    )

    parser.add_argument(
        "-o",
        "--output",
        default="screenshot.png",
        help="Archivo PNG de salida.",
    )

    parser.add_argument(
        "--width",
        type=int,
        default=1440,
        help="Ancho del viewport en píxeles.",
    )

    parser.add_argument(
        "--timeout",
        type=int,
        default=30_000,
        help="Tiempo máximo de carga en milisegundos.",
    )

    parser.add_argument(
        "--chromium",
        help="Ruta opcional al ejecutable Chromium del sistema (por defecto detecta chromium del sistema).",
    )

    parser.add_argument(
        "--delay",
        type=int,
        default=500,
        help="Espera adicional antes de capturar, en milisegundos.",
    )

    args = parser.parse_args()

    try:
        source = normalize_source(args.source)
        output = Path(args.output).expanduser().resolve()
        output.parent.mkdir(parents=True, exist_ok=True)

        with sync_playwright() as playwright:
            launch_options: dict[str, object] = {
                "headless": True,
                "args": [
                    "--disable-gpu",
                    "--hide-scrollbars",
                    "--disable-dev-shm-usage",
                    "--disable-font-subpixel-positioning",
                    "--disable-lcd-text",
                    "--no-sandbox",
                ],
            }

            chromium_path = args.chromium or os.getenv("FULLPAGE_CHROMIUM") or os.getenv("SCREENSHOT_CHROMIUM")

            if not chromium_path:
                for candidate in ("chromium", "chromium-browser", "google-chrome", "google-chrome-stable", "chrome"):
                    path = which(candidate)
                    if path:
                        chromium_path = path
                        break

            if chromium_path:
                launch_options["executable_path"] = chromium_path

            browser = playwright.chromium.launch(**launch_options)

            page = browser.new_page(
                viewport={
                    "width": args.width,
                    "height": 900,
                },
                device_scale_factor=1,
            )

            page.goto(
                source,
                wait_until="networkidle",
                timeout=args.timeout,
            )

            page.wait_for_timeout(args.delay)

            page.screenshot(
                path=str(output),
                full_page=True,
                animations="disabled",
            )

            browser.close()

        print(output)

    except FileNotFoundError as error:
        print(error, file=sys.stderr)
        raise SystemExit(1)

    except TimeoutError:
        print("La página excedió el tiempo máximo de carga.", file=sys.stderr)
        raise SystemExit(2)

    except Error as error:
        error_text = str(error)
        print(f"Error de Chromium: {error_text}", file=sys.stderr)

        if "libglib-2.0.so.0" in error_text:
            print(
                "Sugerencia: usa Chromium del sistema y pasa --chromium=...",
                file=sys.stderr,
            )
            print(
                'Ejemplo: --chromium "$(command -v chromium)"',
                file=sys.stderr,
            )

        raise SystemExit(3)


if __name__ == "__main__":
    main()
