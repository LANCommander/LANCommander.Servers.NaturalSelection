# Natural Selection Server (Docker)

This repository provides a Dockerized **Natural Selection** dedicated server. Natural Selection is a Half-Life mod.
The image builds on [`lancommander/halflife`](https://github.com/LANCommander/LANCommander.Servers.HalfLife). It installs HLDS via SteamCMD, then installs the mod from the community-maintained [ENSL Natural Selection v3.3](https://github.com/ENSL/NS) releases. It supports file overlaying using OverlayFS.

---

## Features

- Natural Selection v3.3 (ENSL community build) on the current Half-Life dedicated server
- Downloads HLDS via SteamCMD and the mod from GitHub releases on first start
- Pin or change the mod version with `NS_VERSION`, or point `NS_URL` at any release zip
- Supports file overlaying using OverlayFS (no file copying required)
- Optional HTTP file server for `sv_downloadurl` fast downloads

## Docker Compose Example

```yaml
services:
  ns-server:
    image: lancommander/naturalselection:latest
    container_name: my-ns-server

    ports:
      - "27015:27015/udp"

    volumes:
      - ./config:/config

    environment:
      START_ARGS: "-game ns -port 27015 +maxplayers 24 +map ns_eon"

    # Overlayfs needs SYS_ADMIN, and the entrypoint must run as root to mount it
    user: root
    cap_add:
      - SYS_ADMIN
    security_opt:
      - apparmor:unconfined

    restart: unless-stopped
```

---

## Directory Layout (Host)

```text
.
└── config/
    ├── Server/            # Installed files (auto-created, don't edit)
    │   ├── hlds_run
    │   ├── valve/         # Half-Life, from SteamCMD
    │   └── ns/            # Natural Selection, from the ENSL release zip
    ├── Overlay/           # Your files, layered on top of Server/
    │   └── ns/
    │       ├── server.cfg
    │       ├── mapcycle.txt
    │       └── maps/      # Custom maps
    ├── Merged/            # Overlayfs merged view (auto-created, the server runs here)
    └── Scripts/
        └── Hooks/         # PowerShell scripts run at container lifecycle hooks
```

`Server/ns` is deleted and re-extracted whenever the release URL changes, so put your changes in `Overlay/ns`.

---

## Environment Variables

These are in addition to the [Half-Life image's variables](https://github.com/LANCommander/LANCommander.Servers.HalfLife#environment-variables).

| Variable | Description | Default |
|----------|-------------|---------|
| `NS_VERSION` | ENSL release tag to install | `v3.3b9` |
| `NS_URL` | Full URL of a release zip, which overrides `NS_VERSION`. The zip must contain an `ns/` folder. | |
| `START_ARGS` | Arguments passed to the server | `-game ns -console -port 27015 +maxplayers 24 +map ns_eon` |
| `HTTP_FILESERVER_WEB_ROOT` | Directory served by the HTTP file server | `/config/Merged/ns` |

`GAME_MOD` stays `valve`. Natural Selection only needs the base Half-Life content.

The mod is installed during the `PostSteamInstallGame` hook, so it is skipped when `STEAM_APP_UPDATE` is `false`.

See [Documentation/Docker.md](Documentation/Docker.md) for more detail.

---

## Building

The image is built `FROM lancommander/halflife:latest` by default. To build against a local base image:

```bash
docker build --build-arg BASE_IMAGE=lancommander/halflife:local -t lancommander/naturalselection:local .
```

---

## License

SteamCMD, game servers and Natural Selection are distributed under their respective licenses.
This repository contains only Docker build logic and helper scripts licensed under MIT.
