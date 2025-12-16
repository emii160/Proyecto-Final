FROM almalinux:8
 
# imagen1 - Herramientas base

RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
      rpm-build rpm-sign rpmdevtools createrepo_c dnf-plugins-core \
      git curl ca-certificates which openssl-devel readline-devel zlib-devel \
      zlib-devel bzip2 bzip2-devel libffi-devel make tar && \
    dnf clean all && rm -rf /var/cache/dnf
 
 
# imagen2 - Ruby con rbenv

RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    /usr/bin/env bash -lc 'cd /usr/local/rbenv && src/configure && make -C src'
 
ENV RBENV_ROOT=/usr/local/rbenv
ENV PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:${PATH}"
RUN /bin/bash -lc "rbenv install 3.1.2 && rbenv global 3.1.2"
RUN /bin/bash -lc "rbenv versions && ruby --version && gem --version"
 
 
# imagen3 - Node.js con NVM

ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p "$NVM_DIR" && \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
 
SHELL ["/bin/bash", "-lc"] 
RUN source "$NVM_DIR/nvm.sh" && \

    nvm install 16 && \
    nvm install 22 && \
    nvm alias default 22 && \
    npm install -g yarn && \
    node -v && npm -v && yarn -v
 
# imagen4 - Python 3.9

RUN dnf -y module enable python39 && \
    dnf -y install python39 python39-pip python39-setuptools && \
    alternatives --set python3 /usr/bin/python3.9 && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    dnf clean all && rm -rf /var/cache/dnf
 
 
# imagen5 - Apache JMeter

ENV JMETER_VERSION=5.6.3
ENV JMETER_HOME=/opt/jmeter
ENV PATH="$JMETER_HOME/bin:$PATH"
RUN curl -L https://downloads.apache.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
    -o /tmp/jmeter.tgz && \
    mkdir -p /opt && \
    tar -xzf /tmp/jmeter.tgz -C /opt && \
    mv /opt/apache-jmeter-${JMETER_VERSION} $JMETER_HOME && \
    rm -f /tmp/jmeter.tgz
 
 
# Perfil de shell para login no interactivo

RUN printf '%s\n' \
  'export RBENV_ROOT=/usr/local/rbenv' \
  'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' \
  'eval "$(rbenv init - bash)"' \
  'export NVM_DIR=/usr/local/nvm' \
  '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' \

  'export PATH="/opt/venv/bin:$PATH"' \
  'export JMETER_HOME=/opt/jmeter' \
  'export PATH="$JMETER_HOME/bin:$PATH"' \
> /etc/profile.d/devstack.sh
 
 
WORKDIR /workspace

SHELL ["/bin/bash","-lc"]

CMD ["/bin/bash"]s