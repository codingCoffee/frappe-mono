FROM python:3.14.4-slim-trixie

LABEL org.opencontainers.image.source=https://github.com/codingcoffee/frappe-docker
LABEL maintainer="Ameya Shenoy <shenoy.ameya@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANGUAGE=C.UTF-8
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Node.js
ARG NODE_VERSION=24.14.1
RUN set -ex \
  && apt update \
  && apt install -y --no-install-recommends \
    curl \
    xz-utils \
    ca-certificates \
  && ARCH="$(dpkg --print-architecture)" \
  && case "$ARCH" in \
       amd64) NODE_ARCH="linux-x64" ;; \
       arm64) NODE_ARCH="linux-arm64" ;; \
       *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
     esac \
  && curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-${NODE_ARCH}.tar.xz" \
  && tar -xJf "node-v${NODE_VERSION}-${NODE_ARCH}.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v${NODE_VERSION}-${NODE_ARCH}.tar.xz"

# Install Yarn from official repo
RUN set -ex \
  && apt install -y --no-install-recommends \
    gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /etc/apt/keyrings/yarn-archive-keyring.gpg > /dev/null \
  && echo "deb [signed-by=/etc/apt/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt update \
  && apt install -y --no-install-recommends \
    yarn

# Install wkhtmltopdf 0.12.6.1-3 (with patched Qt)
ARG WKHTMLTOPDF_VERSION=0.12.6.1-3
RUN set -ex \
  && apt install -y --no-install-recommends \
    fontconfig \
    libjpeg62-turbo \
    libxrender1 \
    libxext6 \
    xfonts-75dpi \
    xfonts-base \
  && ARCH="$(dpkg --print-architecture)" \
  && curl -fsSLo /tmp/wkhtmltox.deb \
    "https://github.com/wkhtmltopdf/packaging/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox_${WKHTMLTOPDF_VERSION}.bookworm_${ARCH}.deb" \
  && apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb \
  && rm /tmp/wkhtmltox.deb

RUN set -ex \
  && apt install -y --no-install-recommends \
    sudo \
    git \
    gcc \
    pkg-config \
    mariadb-client \
    libmariadb-dev

RUN set -ex \
  && apt install -y --no-install-recommends \
    nginx \
    supervisor

# Add frappe user and setup sudo
RUN groupadd -g 1000 frappe \
  && useradd -ms /bin/bash -u 1000 -g 1000 -G sudo frappe \
  && printf '# Sudo rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/frappe \
  && chown -R 1000:1000 /home/frappe

USER frappe
ENV PATH="${PATH}:/home/frappe/.local/bin"
WORKDIR /home/frappe

ENV BENCH_GIT_BRANCH=develop
ENV BENCH_GIT_REPO_URL=https://github.com/frappe/bench
ENV BENCH_LOCAL_PATH="bench-repo"

ENV FRAPPE_GIT_REPO_URL=https://github.com/frappe/frappe.git
ENV FRAPPE_GIT_BRANCH=v16.15.0
ENV FRAPPE_LOCAL_PATH=frappe-bench
ENV FRAPPE_PYTHON=python

RUN set -ex \
  && git clone -b "$BENCH_GIT_BRANCH" "$BENCH_GIT_REPO_URL" "$BENCH_LOCAL_PATH" --depth 1 \
  && pip install --user -e bench-repo \
  && rm -rf ~/.cache/pip \
  && bench init "$FRAPPE_LOCAL_PATH" --frappe-path "$FRAPPE_GIT_REPO_URL" --frappe-branch "$FRAPPE_GIT_BRANCH" --python "$FRAPPE_PYTHON" --no-backups --skip-redis-config-generation --skip-assets --no-procfile \
  && cd "$FRAPPE_LOCAL_PATH" \
  && bench setup requirements

WORKDIR /home/frappe/frappe-bench
USER root
