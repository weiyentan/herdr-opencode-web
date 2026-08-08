# ttyd as the browser access mechanism

ttyd provides browser-based terminal access by exposing Herdr's TUI over WebSocket on port 7681. It was chosen because it is lightweight, has no dependencies beyond a single binary, supports WebSocket natively (required for interactive terminal sessions), and works across architectures (amd64/arm64).

The trade-off is that ttyd has no built-in authentication — which is why an external auth proxy is required for any non-localhost deployment.
