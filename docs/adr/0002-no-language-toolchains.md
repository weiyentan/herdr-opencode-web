# No language toolchains in the image

The image does not include Node.js, Python, Ansible, PowerShell, Go, Rust, Java, GCC, Make, or Docker/Podman build tooling — even though OpenCode may generate code in those languages.

OpenCode can generate and edit source files without these runtimes. Build, lint, test, package, and deploy belong in CI, AWX, or another purpose-built environment. This keeps the image small and focused. Tools can be added later if there is a demonstrated need.
