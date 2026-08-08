# herdr-opencode-web

Portable browser-accessible development container running [OpenCode](https://opencode.ai) and [Herdr](https://herdr.dev) behind [ttyd](https://github.com/tsl0922/ttyd).

## What this is

A small container image that provides:

- OpenCode (AI coding agent)
- Herdr (terminal shell/TUI)
- ttyd (browser-based terminal access on port 7681)
- Git with SSH support

It is deliberately **not** a build or CI environment. Compilation, testing, packaging, and deployment belong in CI, AWX, or another purpose-built environment.

## Architecture

```text
Browser
   |
   v
ttyd :7681
   |
   v
Herdr
   |
   +-- OpenCode
   +-- Git
   +-- shell
   |
   v
/workspace
```

## Quick start

### Build

```bash
docker build -t herdr-opencode:latest .
```

### Run

```bash
docker run --rm -it \
  -p 7681:7681 \
  -v "$(pwd)/workspace:/home/developer/workspace" \
  herdr-opencode:latest
```

Open http://localhost:7681 in your browser.

### Persistent deployment

```bash
docker run -d \
  --name herdr-dev \
  --restart unless-stopped \
  -p 7681:7681 \
  -v herdr-workspace:/home/developer/workspace \
  -v herdr-config:/home/developer/.config \
  -v herdr-data:/home/developer/.local/share \
  herdr-opencode:latest
```

## Kubernetes

The image is designed to work with an authentication sidecar. The Kubernetes Service should expose only the auth proxy — never ttyd directly.

See [docs/adr/0001-authentication-outside-image.md](docs/adr/0001-authentication-outside-image.md) for the rationale.

### Persistent volumes

Mount PVCs at:

- `/home/developer/workspace` — repositories
- `/home/developer/.config` — Herdr and OpenCode config
- `/home/developer/.local/share` — application state

## What is intentionally not included

The image does not contain programming-language toolchains. OpenCode can generate and edit source files without them. Add tools only when there is a demonstrated need.

Not included: Node.js, Python, Ansible, PowerShell, Go, Rust, Java, GCC, Make, Docker/Podman build tooling.

## Security

- Runs as a non-root user
- Do not expose ttyd directly to the public Internet
- Put an authenticated reverse proxy or sidecar in front of it
- Do not bake credentials, keys, or secrets into the image
- Inject secrets at runtime via Docker secrets, Kubernetes Secrets, or similar
