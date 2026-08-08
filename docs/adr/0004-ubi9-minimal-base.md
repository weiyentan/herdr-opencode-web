# UBI9 minimal as base image

The image uses `registry.access.redhat.com/ubi9/ubi-minimal:9.8` rather than Alpine, Debian slim, or Ubuntu. UBI minimal provides a small, Red Hat-supported base with `microdnf` for package management, broad compatibility with enterprise environments, and no licensing concerns for redistribution. The tag is pinned to the 9.8 minor version for reproducible builds.
