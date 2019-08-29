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

# Setup the environment
ENV REPO_BRANCH=master
RUN git config --global user.name "Hacker"
COPY .bashrc /root

COPY startup.sh /
CMD ["/bin/bash", "/startup.sh"]
