FROM almalinux:8

# Variables de entorno globales
ENV RBENV_ROOT=/usr/local/rbenv \
    NVM_DIR=/usr/local/nvm \
    PATH="/opt/venv/bin:/usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH"

# 1. Instalar herramientas base (imagen1)
RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
      rpm-build rpm-sign rpmdevtools createrepo_c dnf-plugins-core \
      git curl ca-certificates which openssl-devel readline-devel zlib-devel \
      bzip2 bzip2-devel libffi-devel make wget unzip java-11-openjdk && \
    dnf clean all && rm -rf /var/cache/dnf

# 2. Instalar rbenv y Ruby (imagen2) - FORMA CORRECTA
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    cd /usr/local/rbenv && src/configure && make -C src

# Instalar Ruby usando script bash completo
RUN /bin/bash -c ' \
    export RBENV_ROOT=/usr/local/rbenv && \
    export PATH="$RBENV_ROOT/bin:$PATH" && \
    eval "$(rbenv init -)" && \
    rbenv install 3.1.2 && \
    rbenv global 3.1.2'

# 3. Instalar NVM y Node.js (imagen3) - FORMA CORRECTA
RUN mkdir -p /usr/local/nvm && \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Instalar Node.js dentro de un script bash
RUN /bin/bash -c ' \
    [ -s "/usr/local/nvm/nvm.sh" ] && \. "/usr/local/nvm/nvm.sh" && \
    nvm install 16 && \
    nvm install 22 && \
    nvm alias default 22 && \
    npm install -g yarn'

# 4. Instalar Python (imagen4)
RUN dnf -y module enable python39 && \
    dnf -y install python39 python39-pip python39-setuptools && \
    alternatives --set python3 /usr/bin/python3.9 && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    dnf clean all && rm -rf /var/cache/dnf

# 5. Instalar SonarScanner (para análisis SonarQube)
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip && \
    unzip sonar-scanner-cli-*.zip -d /opt && \
    mv /opt/sonar-scanner-* /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner && \
    rm -f sonar-scanner-cli-*.zip

# 6. Preparar JMeter (opcional, se puede descargar durante ejecución)
RUN mkdir -p /opt/jmeter && \
    wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.2.tgz -P /tmp && \
    tar -xzf /tmp/apache-jmeter-5.6.2.tgz -C /opt/jmeter && \
    rm -f /tmp/apache-jmeter-5.6.2.tgz

# 7. Script de inicialización que SI se ejecuta al arrancar
RUN printf '%s\n' \
    '#!/bin/bash' \
    'export RBENV_ROOT=/usr/local/rbenv' \
    'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' \
    'eval "$(rbenv init - bash)"' \
    'export NVM_DIR=/usr/local/nvm' \
    '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' \
    'export PATH="/opt/venv/bin:$PATH"' \
    'export PATH="/opt/jmeter/apache-jmeter-5.6.2/bin:$PATH"' \
    'exec "$@"' > /usr/local/bin/init-env.sh && \
    chmod +x /usr/local/bin/init-env.sh

# 8. Archivo de perfil para shells interactivos
RUN printf '%s\n' \
    'export RBENV_ROOT=/usr/local/rbenv' \
    'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' \
    'eval "$(rbenv init - bash)"' \
    'export NVM_DIR=/usr/local/nvm' \
    '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' \
    'export PATH="/opt/venv/bin:$PATH"' \
    'export PATH="/opt/jmeter/apache-jmeter-5.6.2/bin:$PATH"' > /etc/profile.d/devstack.sh

# 9. Workdir y entrypoint que ASEGURA que el entorno se cargue
WORKDIR /workspace

# Entrypoint que carga el entorno antes de cualquier comando
ENTRYPOINT ["/bin/bash", "/usr/local/bin/init-env.sh"]
CMD ["/bin/bash"]