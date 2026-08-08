FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

ENV HOME=/home/${USERNAME}
ENV PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"

# Basic runtime and development utilities
RUN microdnf install -y \
        bash \
        ca-certificates \
        curl \
        git \
        openssh-clients \
        jq \
        tar \
        gzip \
        unzip \
        shadow-utils \
    && microdnf clean all \
    && rm -rf /var/cache/yum

# Create a non-root developer account
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd \
        --uid ${USER_UID} \
        --gid ${USER_GID} \
        --create-home \
        --shell /bin/bash \
        ${USERNAME}

# Install OpenCode using its standalone installer
RUN mkdir -p /opt/opencode \
    && HOME=/opt/opencode \
       curl -fsSL https://opencode.ai/install | bash \
    && cp /opt/opencode/.opencode/bin/opencode /usr/local/bin/opencode \
    && chmod 0755 /usr/local/bin/opencode \
    && rm -rf /opt/opencode

# Install Herdr as the developer user
USER ${USERNAME}

RUN mkdir -p \
        "${HOME}/.local/bin" \
        "${HOME}/.config" \
        "${HOME}/.local/share" \
        "${HOME}/workspace" \
    && curl -fsSL https://herdr.dev/install.sh | sh

# Install ttyd
USER root

ARG TTYD_VERSION=1.7.7
ARG TARGETARCH

RUN case "${TARGETARCH}" in \
        amd64) TTYD_ARCH="x86_64" ;; \
        arm64) TTYD_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && curl -fsSL \
       "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" \
       -o /usr/local/bin/ttyd \
    && chmod 0755 /usr/local/bin/ttyd

USER ${USERNAME}

WORKDIR ${HOME}/workspace

EXPOSE 7681

VOLUME ["/home/developer/workspace"]

CMD ["ttyd", "-W", "-p", "7681", "herdr"]
