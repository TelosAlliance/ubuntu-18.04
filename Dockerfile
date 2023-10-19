# syntax=docker/dockerfile:1.3-labs
# vim:syntax=dockerfile
FROM --platform=$BUILDPLATFORM ubuntu:bionic

# Set this before `apt-get` so that it can be done non-interactively
ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/New_York
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# Golang env
ENV GO_PARENT_DIR /opt
ENV GOROOT $GO_PARENT_DIR/go
ENV GOPATH $HOME/work/

# Rust env
ENV RUST_HOME /opt/rust
ENV CARGO_HOME $RUST_HOME
ENV RUSTUP_HOME $RUST_HOME/.rustup

# Set PATH to include custom bin directories
ENV PATH $GOPATH/bin:$GOROOT/bin:$RUST_HOME/bin:$PATH

# testing
ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETOS
ARG TARGETPLATFORM
ENV BUILDPLATFORM=${BUILDPLATFORM}
ENV TARGETARCH=${TARGETARCH}
ENV TARGETOS=${TARGETOS}
ENV TARGETPLATFORM=${TARGETPLATFORM}
RUN echo "*******************\nI am running on $BUILDPLATFORM, building for $TARGETPLATFORM\n *******************"

# KEEP PACKAGES SORTED ALPHABETICALY
# Do everything in one RUN command
RUN /bin/bash <<EOF

set -euxo pipefail
# Install packages needed to set up third-party repositories
apt-get update
apt-get install -y --no-install-recommends \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  gnupg \
  python3 \
  python3-pip \
  software-properties-common \
  wget
# Install AWS cli
#pip3 install awscli
# Use kitware's CMake repository for up-to-date version
curl -sSf https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
# Use NodeSource's NodeJS 12.x repository
#curl -sSf https://deb.nodesource.com/setup_12.x | bash -
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update && apt-get install nodejs -y
# Install nvm binary
curl -sSf https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
# Install nodejs/npm
apt-get update
apt-get install -y --no-install-recommends \
  nodejs
# Install other javascript package managers
npm install -g yarn pnpm
# Install newer version of Go than is included with Ubuntu
curl -sSf "https://dl.google.com/go/go1.21.3.linux-${TARGETARCH}.tar.gz" | tar -xz -C "$GO_PARENT_DIR"
# Install everything else
# NOTE: Can't install libboost-all-dev:i386 because it conflicts with libboost-all-dev
apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  bc \
  binutils \
  bzip2 \
  cmake \
  cpio \
  cppcheck \
  coreutils \
  default-jdk \
  device-tree-compiler \
  elfutils \
  fftw3-dev \
  file \
  g++ \
  gawk \
  gcc \
  gdb \
  gettext \
  git \
  gosu \
  gzip \
  kmod \
  libasound2-dev \
  libavahi-compat-libdnssd-dev \
  libboost-all-dev \
  libc6-dev \
  libcurl4 \
  libcurl4-openssl-dev \
  libsndfile1-dev \
  libssl-dev \
  libtool \
  libwebsocketpp-dev \
  libwebsockets-dev \
  locales-all \
  lzop \
  make \
  ncurses-dev \
  patch \
  perl \
  python \
  python-dev \
  openssh-client \
  rsync \
  scons \
  sed \
  shellcheck \
  subversion \
  swig \
  tar \
  unzip \
  uuid-dev \
  valgrind \
  vim \
  zip \
  zlib1g-dev

case "$TARGETPLATFORM" in
    "linux/amd64")
        #echo "export RUST_TARGET=x86_64-unknown-linux-musl" >> evars
        #dpkg --add-architecture i386
        #apt-get update
        #apt-get upgrade
        #echo "installing i386 components.."
        #apt-get install -y --no-install-recommends \
        #  libboost-dev:i386 \
        #  libboost-program-options-dev:i386 \
        #  zlib1g-dev:i386
        # Install Rust, with MUSL libc toolchain
        curl -sSf https://sh.rustup.rs | sh -s -- -y
        curl -sSf https://just.systems/install.sh | bash -s -- --to "$RUST_HOME/bin"
        cargo install cargo-bundle-licenses
        cargo install cargo-deny
        cargo install cargo-license
        rustup target install x86_64-unknown-linux-musl
        rm -rf "$RUST_HOME/registry" "$RUST_HOME/git"
        chmod 777 "$RUST_HOME"
        apt-get install -y musl-tools
        ;;
    "linux/arm64")
        # Install Rust, with MUSL libc toolchain
        curl -sSf https://sh.rustup.rs | sh -s -- -y
        curl -sSf https://just.systems/install.sh | bash -s -- --to "$RUST_HOME/bin"
        cargo install cargo-bundle-licenses
        cargo install cargo-deny
        cargo install cargo-license
        rustup target install aarch64-unknown-linux-musl
        rm -rf "$RUST_HOME/registry" "$RUST_HOME/git"
        chmod 777 "$RUST_HOME"
        apt-get install -y musl-tools
        #echo "export RUST_TARGET=aarch64-unknown-linux-musl" >> evars
        ;;
    *)
        echo "Unhandled architecture."
        exit 1
        ;;
esac

apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

COPY patch /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
