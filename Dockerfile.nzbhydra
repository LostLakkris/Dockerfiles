FROM linuxserver/hydra2:latest
ENV SET_SERVICE="nzbhydra"
RUN apt-get update -y && \
    apt-get install -y jq python-pip && \
    pip install yq && \
    apt-get -y purge python-pip && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*
COPY s6.lakkris/ /
