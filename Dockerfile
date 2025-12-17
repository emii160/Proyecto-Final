FROM almalinux:8

# 1. Herramientas base (RPM, desarrollo)
RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
      rpm-build rpm-sign rpmdevtools createrepo_c dnf-plugins-core \
      git curl ca-certificates which openssl-devel \
      zlib-devel bzip2 bzip2-devel libffi-devel make \
      unzip tar && \
    dnf clean all && rm -rf /var/cache/dnf

# 2. Instalar rbenv y Ruby
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    /usr/bin/env bash -lc 'cd /usr/local/rbenv && src/configure && make -C src'

ENV RBENV_ROOT=/usr/local/rbenv
ENV PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:${PATH}"

RUN /bin/bash -lc "rbenv install 3.1.2 && rbenv global 3.1.2"
RUN /bin/bash -lc "ruby --version && gem --version"

# 3. Instalar Node.js y yarn
RUN curl -fsSL https://rpm.nodesource.com/setup_22.x | bash - && \
    dnf install -y nodejs && \
    npm install -g yarn && \
    node -v && npm -v && yarn -v

# 4. Instalar Python 3.9
RUN dnf -y module enable python39 && \
    dnf -y install python39 python39-pip python39-setuptools && \
    alternatives --set python3 /usr/bin/python3.9 && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    dnf clean all && rm -rf /var/cache/dnf

# 5. Configurar entorno para sesiones bash
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/custom.sh && \
    echo 'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' >> /etc/profile.d/custom.sh && \
    echo 'eval "$(rbenv init - bash)"' >> /etc/profile.d/custom.sh && \
    echo 'export PATH="/opt/venv/bin:$PATH"' >> /etc/profile.d/custom.sh

WORKDIR /workspace

# 6. Configurar entrypoint para cargar entorno
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]