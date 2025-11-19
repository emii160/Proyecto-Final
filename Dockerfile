FROM almalinux:8

#imagen1
RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
      rpm-build rpm-sign rpmdevtools createrepo_c dnf-plugins-core \
      git curl ca-certificates which openssl-devel readline-devel zlib-devel \
      bzip2 bzip2-devel libffi-devel make && \
    dnf clean all && rm -rf /var/cache/dnf

# imagen2 
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    /usr/bin/env bash -lc 'cd /usr/local/rbenv && src/configure && make -C src'
ENV RBENV_ROOT=/usr/local/rbenv
ENV PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:${PATH}"
RUN /bin/bash -lc "rbenv install 3.1.2 && rbenv global 3.1.2"
RUN /bin/bash -lc "rbenv versions && ruby --version && gem --version"

#imagen3
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p "$NVM_DIR" && \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
SHELL ["/bin/bash", "-lc"]
RUN source "$NVM_DIR/nvm.sh" && \
    nvm install 16 && nvm install 22 && nvm alias default 22 && \
    npm install -g yarn && \
    node -v && npm -v && yarn -v

# imagen4
RUN dnf -y module enable python39 && \
    dnf -y install python39 python39-pip python39-setuptools && \
    alternatives --set python3 /usr/bin/python3.9 && \
    python3 -m venv /opt/venv && /opt/venv/bin/pip install --upgrade pip && \
    dnf clean all && rm -rf /var/cache/dnf

# 5. Perfil de shell para “login” no interactivo
RUN printf '%s\n' \
  'export RBENV_ROOT=/usr/local/rbenv' \
  'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' \
  'eval "$(rbenv init - bash)"' \
  'export NVM_DIR=/usr/local/nvm' \
  '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' \
  'export PATH="/opt/venv/bin:$PATH"' \
  > /etc/profile.d/devstack.sh

WORKDIR /workspace
SHELL ["/bin/bash","-lc"]
CMD ["/bin/bash"]