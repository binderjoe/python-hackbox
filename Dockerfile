FROM ubuntu:18.04

RUN apt-get update

# Azure CLI
RUN apt-get -y install ca-certificates curl apt-transport-https lsb-release gnupg
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
    
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

RUN apt-get update && apt-get install azure-cli

# OS packages
RUN apt-get install -y build-essential jq git libmysqlclient-dev python3 python3-dev python3-pip python3-venv

# Enable sshd
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
EXPOSE 22

# Pre-pull dependencies
WORKDIR /root/hack
ARG REQ=https://raw.githubusercontent.com/noelbundick/python-hackbox/master/requirements.txt
RUN curl -Lo requirements.txt $REQ \
    && python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip install pip wheel -U \
    && pip install -r requirements.txt \
    && rm requirements.txt

# Preinstall VS Code server
ARG VSCODE_COMMIT=f06011ac164ae4dc8e753a3fe7f9549844d15e35
RUN mkdir -p ~/.vscode-server/bin/$VSCODE_COMMIT \
    && cd ~/.vscode-server/bin/$VSCODE_COMMIT \
    && curl -L https://update.code.visualstudio.com/commit:$VSCODE_COMMIT/server-linux-x64/stable -o vscode-server-linux-x64.tar.gz \
    && tar -xvzf vscode-server-linux-x64.tar.gz --strip-components 1 \
    && rm vscode-server-linux-x64.tar.gz

# Install Python VS Code extension
ARG VSCODE_PYTHON_VERSION=2019.8.30787
RUN apt-get install -y unzip \
    && mkdir -p ~/.vscode-server/extensions \
    && cd ~/.vscode-server/extensions \
    && curl https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/$VSCODE_PYTHON_VERSION/vspackage --compressed -o extension.zip \
    && unzip extension.zip \
    && mv extension ms-python.python-$VSCODE_PYTHON_VERSION \
    && rm '[Content_Types].xml' extension.vsixmanifest extension.zip

# Setup the environment
ENV REPO_BRANCH=master
RUN git config --global user.name "Hacker" \
    && git config --global user.email "hacker@example.com"
COPY .bashrc /root
COPY startup.sh /

CMD ["/bin/bash", "/startup.sh"]
