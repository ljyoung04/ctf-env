FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=orbis

# --------------------------------------------------
# Base packages
# --------------------------------------------------

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    sudo \
    git \
    curl \
    wget \
    openssh-client \
    \
    build-essential \
    gcc-multilib \
    nasm \
    pkg-config \
    libssl-dev \
    liblzma-dev \
    \
    gdb \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-pwntools \
    python3-requests \
    python3-pycryptodome \
    python3-z3 \
    python3-bs4 \
    \
    patchelf \
    checksec \
    file \
    strace \
    ltrace \
    \
    nmap \
    netcat-openbsd \
    socat \
    dnsutils \
    ffuf \
    sqlmap \
    \
    nano \
    jq \
    tmux \
    ripgrep \
    tree \
    unzip \
    eza \
    bubblewrap \
    && rm -rf /var/lib/apt/lists/*


# --------------------------------------------------
# Rename ubuntu -> orbis
# UID/GID 1000 remains unchanged
# --------------------------------------------------

RUN usermod -l "${USERNAME}" ubuntu \
    && groupmod -n "${USERNAME}" ubuntu \
    && usermod -d "/home/${USERNAME}" -m "${USERNAME}" \
    && rm -f /etc/sudoers.d/ubuntu \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" \
        > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"


USER ${USERNAME}
WORKDIR /home/${USERNAME}


# --------------------------------------------------
# Oh My Bash
# --------------------------------------------------

RUN git clone --depth=1 \
        https://github.com/ohmybash/oh-my-bash.git \
        "$HOME/.oh-my-bash" \
    && cp \
        "$HOME/.oh-my-bash/templates/bashrc.osh-template" \
        "$HOME/.bashrc" \
    && sed -i \
        's/^OSH_THEME=.*/OSH_THEME="ht"/' \
        "$HOME/.bashrc"


# --------------------------------------------------
# fzf - latest prebuilt binary
# --------------------------------------------------

RUN mkdir -p "$HOME/.local/bin" \
    && FZF_VERSION="$( \
        curl -Ls -o /dev/null -w '%{url_effective}' \
        https://github.com/junegunn/fzf/releases/latest \
        | sed 's#.*/v##' \
    )" \
    && ARCH="$(dpkg --print-architecture)" \
    && curl -fsSL \
        "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${ARCH}.tar.gz" \
        | tar -xz -C "$HOME/.local/bin"


# --------------------------------------------------
# zoxide
# --------------------------------------------------

RUN curl -sSfL \
    https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
    | bash


# --------------------------------------------------
# Rust
#
# Ubuntu 24.04 apt cargo(1.75)는 너무 오래되어
# 최신 pwninit dependency의 edition2024 처리 불가.
# rustup stable 사용.
# --------------------------------------------------

RUN curl \
        --proto '=https' \
        --tlsv1.2 \
        -sSf \
        https://sh.rustup.rs \
    | sh -s -- -y --profile minimal


ENV PATH="/home/${USERNAME}/.cargo/bin:/home/${USERNAME}/.local/bin:${PATH}"


# --------------------------------------------------
# pwninit
# --------------------------------------------------

RUN cargo install pwninit


# --------------------------------------------------
# Pwndbg
# --------------------------------------------------

RUN git clone --depth=1 \
        https://github.com/pwndbg/pwndbg.git \
        "$HOME/.pwndbg" \
    && cd "$HOME/.pwndbg" \
    && DEBIAN_FRONTEND=noninteractive ./setup.sh


# --------------------------------------------------
# Radare2
# --------------------------------------------------

RUN git clone --depth=1 \
        https://github.com/radareorg/radare2.git \
        /tmp/radare2 \
    && /tmp/radare2/sys/install.sh --install \
    && rm -rf /tmp/radare2

RUN r2pm -U \
    && r2pm -ci r2ghidra

# --------------------------------------------------
# Bash configuration
# --------------------------------------------------

RUN cat >> "$HOME/.bashrc" <<'EOF'

# Local binaries
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# fzf
export FZF_CTRL_R_OPTS='--color=fg+:white,bg+:#333333,pointer:magenta'
eval "$(fzf --bash)"

# zoxide
eval "$(zoxide init bash)"

# eza
alias ls='eza --icons=always'
alias ll='eza -al --icons=always'

EOF


# --------------------------------------------------
# Workspace
# --------------------------------------------------

WORKDIR /workspace

CMD ["/bin/bash"]