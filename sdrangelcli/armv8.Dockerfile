FROM arm64v8/node as base

# Install base packages
RUN apt-get update && apt-get -y install sudo
RUN npm install -g @angular/cli \
    && npm install -g http-server

# Give node user sudo rights and default to it
RUN usermod -a -G sudo node \
    && usermod --shell /bin/bash node
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER node

RUN sudo mkdir /opt/build \
    && sudo chown node:node /opt/build
WORKDIR /opt/build

# Clone sdrangelcli and build final image
FROM base as sdrangelcli
ARG repository
ARG branch
ARG repo_hash
ARG clone_tag
RUN GIT_SSL_NO_VERIFY=true git clone ${repository} -b ${branch} sdrangelcli \
    && echo "${repo_hash}" > /dev/null \
    && echo "${clone_tag}" > /dev/null
WORKDIR /opt/build/sdrangelcli
RUN npm install
RUN ng build --prod

WORKDIR /opt/build/sdrangelcli/dist/sdrangelcli
ENTRYPOINT [ "http-server" ]
