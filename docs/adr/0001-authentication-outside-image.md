# Authentication outside the image

Authentication is intentionally kept out of the container image. In Kubernetes, an auth sidecar handles authentication and proxies to ttyd on localhost:7681. The image contains no auth secrets, domain config, or cluster-specific configuration.

This makes the image reusable across different access-control mechanisms: Clerk, oauth2-proxy, Cloudflare Access, Authelia, Tailscale, VPN, or localhost-only use with no auth at all.
