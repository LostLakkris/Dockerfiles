FROM linuxserver/hydra2:latest
COPY lakkris.s6/ /
RUN apt-get update -y && \
    apt-get install -y jq python-pip && \
    pip install yq && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*
ENV SET_SERVICE="nzbhydra" \
    SET_PORT="5076"
LABEL "lostlakkris.service"="nzbhydra"

HEALTHCHECK --interval=30s --timeout=3s --start-period=5m \
  CMD /scripts/healthcheck.sh || exit 1
