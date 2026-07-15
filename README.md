# Kod3rd Landing Page 🚀

Static Astro site for Kod3rd with local assets and JSON-driven content.

## Despliegue NixOS (módulo nativo)

Se eliminó el uso de `flake.nix` de este repo para dejar un módulo importable en tu host NixOS:
- `kod3.nix`

El módulo levanta la aplicación como **servicio systemd** en puerto **9200** y no depende de nginx ni Cloudflare en el repositorio.

### 1) Obtener `kod3.nix` desde GitHub (raw)

```bash
mkdir -p /etc/nixos/modules
curl -L https://raw.githubusercontent.com/osmargm1202/kod3rd/main/kod3.nix \
  -o /etc/nixos/modules/kod3.nix
```

### 2) O copiar desde este repositorio

```bash
scp /home/osmarg/Code/Kod3rd-landing/kod3.nix root@TU_SERVIDOR:/etc/nixos/modules/kod3.nix
```

### 3) Importar el módulo en tu host NixOS

Añade a `configuration.nix` (o `default.nix`/`hosts/<host>.nix`) el import del módulo:

```nix
imports = [
  ./modules/kod3.nix  # o la ruta donde lo guardaste
];
```

y activa el servicio:

```nix
services.kod3Landing = {
  enable = true;
  source = "/var/lib/kod3rd-landing";   # ruta del proyecto en el server
  bindAddress = "127.0.0.1";             # usa 0.0.0.0 si quieres exponer directo
  port = 9200;
  openFirewall = false;                  # true para exponer puerto directamente
  environment = {
    NODE_ENV = "production";
  };
  # environmentFile = "/etc/nixos/kod3.env"; # opcional, para secretos
};
```

### Variables de entorno

El servicio acepta:

- `services.kod3Landing.environment` (atributos Nix): se inyectan en systemd como `KEY=VALUE`.
- `services.kod3Landing.environmentFile` (opcional): ruta a archivo `KEY=VALUE` por línea para valores sensibles.

Ejemplo de archivo de entorno (`/etc/nixos/kod3.env`):

```bash
NODE_ENV=production
HOST=127.0.0.1
PORT=9200
```

### Comandos de build y despliegue

Si usas config no-flake:

```bash
sudo nixos-rebuild build
sudo nixos-rebuild switch
```

Si tu host usa flake:

```bash
sudo nixos-rebuild build --flake .#nombre-host
sudo nixos-rebuild switch --flake .#nombre-host
```

Verificación:

```bash
systemctl status kod3-landing
journalctl -u kod3-landing -n 200 --since "10 min ago"
curl http://127.0.0.1:9200
```

### Puertos usados

| Servicio | Puerto | Dirección |
|---|---:|---|
| kod3-landing | 9200 | loopback (`127.0.0.1`) por defecto |

---

## 📬 Contacto

📧 kod3rd.44@gmail.com  
📱 +1 (829) 868-2298  
📱 +1 (809) 988-4985  
📸 [Instagram @kod3rd](https://instagram.com/kod3rd)

© 2025 Kod3rd. All rights reserved.
