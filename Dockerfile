FROM almalinux:8

LABEL org.opencontainers.image.authors="tu@correo.com"
LABEL org.opencontainers.image.description="Imagen full: RPM + Ruby (rbenv) + Node (nvm) + Python (pyenv)"

ENV LANG=C.UTF-8

RUN dnf -y install epel-release && \
    dnf -y install \
        rpm-build \
        rpmdevtools \
        createrepo \
        dnf-utils \
        redhat-rpm-config \
        git \
        curl \
        make \
        gcc \
        patch \
        tar \
        gzip \
        bzip2 \
        bzip2-devel \
        readline-devel \
        zlib-devel \
        openssl-devel \
        libffi-devel \
        sqlite-devel \
        xz-devel \
        ca-certificates && \
    dnf clean all

RUN rpmdev-setuptree

ENV RBENV_ROOT=/usr/local/rbenv
ENV PATH=${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:${PATH}

RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} && \
    mkdir -p ${RBENV_ROOT}/plugins && \
    git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build && \
    cd ${RBENV_ROOT} && src/configure && make -C src

ARG RUBY_VERSION=3.1.4

RUN rbenv install -s ${RUBY_VERSION} && \
    rbenv global ${RUBY_VERSION} && \
    rbenv rehash && \
    rbenv exec gem update --system && \
    rbenv exec gem install bundler && \
    rbenv rehash

ENV PYENV_ROOT=/usr/local/pyenv
ENV PATH=${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}

RUN git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT}

ARG PYTHON_VERSION=3.9.19

RUN pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION} && \
    pyenv rehash && \
    pip install --upgrade pip setuptools wheel

ENV NVM_DIR=/usr/local/nvm

RUN mkdir -p ${NVM_DIR} && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

ARG NODE_VERSION_16=16
ARG NODE_VERSION_22=22

RUN bash -lc ". ${NVM_DIR}/nvm.sh && \
    nvm install ${NODE_VERSION_16} && \
    nvm install ${NODE_VERSION_22} && \
    nvm alias default ${NODE_VERSION_22} && \
    nvm use default && \
    npm install -g yarn && \
    nvm cache clear"

ENV PATH=${NVM_DIR}/versions/node/v${NODE_VERSION_22}/bin:${PATH}

WORKDIR /workspace
CMD ["bash"]