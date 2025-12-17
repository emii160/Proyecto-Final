FROM almalinux:8

# ===============================
# 1. Herramientas base
# ===============================
RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
      git curl ca-certificates which \
      rpm-build rpm-sign rpmdevtools createrepo_c dnf-plugins-core \
      openssl-devel readline-devel zlib-devel \
      bzip2 bzip2-devel libffi-devel make \
      unzip tar wget && \
    dnf clean all && rm -rf /var/cache/dnf

# ===============================
# 2. Ruby con rbenv
# ===============================
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    /usr/bin/env bash -lc 'cd /usr/local/rbenv && src/configure && make -C src'

ENV RBENV_ROOT=/usr/local/rbenv
ENV PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:${PATH}"

RUN /bin/bash -lc "rbenv install 3.1.2 && rbenv global 3.1.2"
RUN /bin/bash -lc "ruby -v && gem -v"

# ===============================
# 3. Node.js con NVM
# ===============================
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p "$NVM_DIR" && \
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

SHELL ["/bin/bash", "-lc"]

RUN source "$NVM_DIR/nvm.sh" && \
    nvm install 22 && \
    nvm alias default 22 && \
    npm install -g yarn && \
    node -v && npm -v && yarn -v

# ===============================
# 4. Python 3.9 + venv
# ===============================
RUN dnf -y module enable python39 && \
    dnf -y install python39 python39-pip python39-setuptools && \
    alternatives --set python3 /usr/bin/python3.9 && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    dnf clean all && rm -rf /var/cache/dnf

# ===============================
# 5. Apache JMeter
# ===============================
ENV JMETER_VERSION=5.6.3
RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
    ln -s /opt/apache-jmeter-${JMETER_VERSION} /opt/jmeter && \
    rm -f apache-jmeter-${JMETER_VERSION}.tgz

ENV PATH="/opt/jmeter/bin:${PATH}"

RUN jmeter --version

# ===============================
# 6. SonarQube Scanner CLI
# ===============================
ENV SONAR_SCANNER_VERSION=5.0.1.3006
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip -d /opt && \
    ln -s /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner && \
    rm -f sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip

ENV PATH="/opt/sonar-scanner/bin:${PATH}"

RUN sonar-scanner --version

# ===============================
# 7. Perfil de shell para Jenkins
# ===============================
RUN printf '%s\n' \
  'export RBENV_ROOT=/usr/local/rbenv' \
  'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' \
  'eval "$(rbenv init - bash)"' \
  'export NVM_DIR=/usr/local/nvm' \
  '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' \
  'export PATH="/opt/venv/bin:/opt/jmeter/bin:/opt/sonar-scanner/bin:$PATH"' \
  > /etc/profile.d/devstack.sh

WORKDIR /workspace
CMD ["/bin/bash"]
