{ config, lib, pkgs, ... }:

let
  cfg = config.services.kod3Landing;

  mkEnvVar = name: value: "${name}=${toString value}";
  staticSite = pkgs.stdenvNoCC.mkDerivation {
    pname = "kod3rd-landing-dist";
    version = "1.0.0";

    src = lib.cleanSource cfg.source;

    nativeBuildInputs = [ pkgs.nodejs_20 ];

    buildPhase = ''
      npm ci
      npm run build
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
    '';
  };

  envVars = lib.mapAttrsToList mkEnvVar cfg.environment;

  serveScript = pkgs.writeShellScript "kod3-landing-serve" ''
    set -eu
    : "''${PORT:=${toString cfg.port}}"
    : "''${HOST:=${cfg.bindAddress}}"
    exec ${pkgs.python3}/bin/python3 -m http.server "$PORT" --bind "$HOST" --directory "${staticSite}" 
  '';
in {
  options.services.kod3Landing = {
    enable = lib.mkEnableOption "kod3rd landing static site service";

    source = lib.mkOption {
      type = lib.types.path;
      description = ''Ruta local del proyecto (directorio que contiene package.json, src, etc.).'';
      example = "/var/lib/kod3rd";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Dirección IP donde el servicio escucha.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9200;
      description = "Puerto de escucha del servicio.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Si es true, abre el puerto localmente.
        Por defecto está cerrado porque el servicio suele ir detrás de reverse proxy o túnel.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.int);
      default = {};
      description = ''
        Variables de entorno usadas por el servicio al iniciar.
        Se inyectan en el proceso vía systemd.
      '';
      example = {
        NODE_ENV = "production";
        STATIC_ROOT = "/app";
      };
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Archivo opcional con variables KEY=VALUE por línea.
        Útil para secretos.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.kod3Landing = { };
    users.users.kod3Landing = {
      isSystemUser = true;
      group = "kod3Landing";
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.kod3-landing = {
      description = "Kod3rd landing static site";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        User = "kod3Landing";
        Group = "kod3Landing";
        WorkingDirectory = cfg.source;
        ExecStart = "${serveScript}";

        Environment = envVars;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

        Restart = "always";
        RestartSec = "3s";

        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RestrictRealtime = true;

        CapabilityBoundingSet = [ ];
        ReadOnlyPaths = [ staticSite ];
        AmbientCapabilities = [ ];
        # SPA estático no escribe estado.
        ReadWritePaths = [ ];
        LimitNOFILE = 16384;
        MemoryMax = "512M";
        TasksMax = 256;
      };
    };
  };
}
