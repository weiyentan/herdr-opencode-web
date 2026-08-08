# ---- Builder stage ----
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.4 AS builder

RUN microdnf install -y \
        bash \
        ca-certificates \
        curl \
        tar \
        gzip \
        unzip \
    && microdnf clean all

ARG TTYD_VERSION=1.7.7
ARG TARGETARCH

# Install OpenCode
RUN mkdir -p /opt/opencode \
    && HOME=/opt/opencode \
       curl -fsSL https://opencode.ai/install | bash \
    && cp /opt/opencode/.opencode/bin/opencode /usr/local/bin/opencode \
    && chmod 0755 /usr/local/bin/opencode

# Install Herdr
ARG USERNAME=developer
ENV HOME=/home/${USERNAME}
RUN mkdir -p "${HOME}/.local/bin" \
    && curl -fsSL https://herdr.dev/install.sh | sh

# Install ttyd
RUN case "${TARGETARCH}" in \
        amd64) TTYD_ARCH="x86_64" ;; \
        arm64) TTYD_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && curl -fsSL \
       "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" \
       -o /usr/local/bin/ttyd \
    && chmod 0755 /usr/local/bin/ttyd

# ---- Runtime stage ----
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.4

ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

ENV HOME=/home/${USERNAME}
ENV PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"

RUN microdnf install -y \
        bash \
        ca-certificates \
        git \
        openssh-clients \
        jq \
        shadow-utils \
    && microdnf clean all \
    && rm -rf /var/cache/yum

# Create non-root user
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd \
        --uid ${USER_UID} \
        --gid ${USER_GID} \
        --create-home \
        --shell /bin/bash \
        ${USERNAME}

# Copy binaries from builder
COPY --from=builder /usr/local/bin/opencode /usr/local/bin/opencode
COPY --from=builder /usr/local/bin/ttyd /usr/local/bin/ttyd
COPY --from=builder /home/${USERNAME}/.local/bin/ ${HOME}/.local/bin/

# Create workspace and config directories
RUN mkdir -p \
        "${HOME}/.config" \
        "${HOME}/.local/share" \
        "${HOME}/workspace" \
    && chown -R ${USERNAME}:${USERNAME} ${HOME}

USER ${USERNAME}

WORKDIR ${HOME}/workspace

EXPOSE 7681

VOLUME ["/home/developer/workspace"]

CMD ["ttyd", "-W", "-p", "7681", "herdr"]
