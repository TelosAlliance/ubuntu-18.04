# vim:syntax=dockerfile
FROM ubuntu:18.04

# Set this before `apt-get` so that it can be done non-interactively
ENV DEBIAN_FRONTEND noninteractive
ENV TZ America/New_York
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV GOROOT /usr/local/go
ENV PATH $GOROOT/bin:$PATH

# KEEP PACKAGES SORTED ALPHABETICALY
# Do everything in one RUN command
RUN dpkg --add-architecture i386 \
  # Install packages needed to set up third-party repositories
  && apt-get update \
  && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    python3 \
    python3-pip \
    software-properties-common \
    wget \
  # Install AWS cli
  && pip3 install awscli \
  # Use kitware's CMake repository for up-to-date version
  && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - \
  && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' \
  # Use NodeSource's NodeJS 12.x repository
  && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  # Install nvm binary
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
  # Install nodejs/npm
  && apt-get update \
  && apt-get install -y \
    nodejs \
  # Install other javascript package managers
  && npm install -g yarn pnpm \
  # Install newer version of Go than is included with Ubuntu
  && wget -c https://dl.google.com/go/go1.14.9.linux-amd64.tar.gz \
  && tar xvf go1.14.9.linux-amd64.tar.gz \
  && mv go /usr/local/ \
  && rm -f go* \
  # Install everything else
  && apt-get install -y \
    autoconf \
    automake \
    bc \
    binutils \
    bzip2 \
    cmake \
    cpio \
    coreutils \
    default-jdk \
    device-tree-compiler \
    elfutils \
    fftw3-dev \
    file \
    g++ \
    g++-multilib \
    gawk \
    gcc \
    gcc-multilib \
    gdb \
    gettext \
    git \
    gosu \
    gzip \
    kmod \
    libasound2-dev \
    libavahi-compat-libdnssd-dev \
    libboost-all-dev \
    # Can't install libboost-all-dev:i386 because it conflicts with libboost-all-dev
    libboost-dev:i386 \
    libboost-program-options-dev:i386 \
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
    zlib1g-dev \
    zlib1g-dev:i386 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

COPY patch /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
