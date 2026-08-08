# Herdr OpenCode Web

A portable development container that provides browser-accessible OpenCode and Herdr through ttyd.

## Language

**Workspace**:
The mounted directory (`/home/developer/workspace`) where repositories are cloned, inspected, edited, and committed.
_Avoid_: workdir, project folder, source directory

**Development container**:
The running instance of this image — a lightweight, browser-accessible environment for code editing and Git operations via Herdr and OpenCode.
_Avoid_: dev container, IDE container, sandbox

**Auth sidecar**:
A separate container in the same Kubernetes Pod that handles authentication and proxies authenticated traffic to ttyd on localhost.
_Avoid_: auth proxy, login container, gateway

**ttyd**:
The terminal multiplexer that exposes Herdr's TUI to the browser over WebSocket on port 7681.
_Avoid_: web terminal, terminal proxy

**Herdr**:
The shell/TUI that runs inside the container and provides the interactive terminal environment where OpenCode operates.
_Avoid_: shell, terminal, CLI

**Persistent volume**:
A Docker named volume or Kubernetes PVC that preserves workspace, config, and data across container restarts.
_Avoid_: storage mount, data volume

## Relationships

- A **Development container** runs **Herdr** as its entrypoint
- **Herdr** hosts **OpenCode** and **Git** as sub-tools
- **ttyd** exposes **Herdr** to the browser
- An **Auth sidecar** sits in front of **ttyd** in Kubernetes deployments
- A **Persistent volume** backs the **Workspace** and config/data directories

## Example dialogue

> **Dev:** "Should we install Python in the **development container** so OpenCode can run tests?"
> **Domain expert:** "No — the **development container** is for editing and committing. Build and test happens in CI or AWX. Keep the image small."

> **Dev:** "Where does the **auth sidecar** sit in the architecture?"
> **Domain expert:** "In Kubernetes, it's in the same Pod. The Service exposes the **auth sidecar** on 8080, which proxies to **ttyd** on localhost:7681. ttyd is never exposed externally."

## Flagged ambiguities

- "workspace" can mean the mounted directory or the entire container experience — resolved: **Workspace** refers specifically to `/home/developer/workspace`.
- "dev container" could mean VS Code dev containers or this image — resolved: use **Development container** to refer to this project's image specifically.
