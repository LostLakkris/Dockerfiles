FROM organizrtools/organizr-v2:latest
COPY lakkris.s6/ /
ENV SET_SERVICE="organizr" \
    SET_PORT="80"
LABEL "lostlakkris.service"="organizr"

HEALTHCHECK --interval=30s --timeout=3s --start-period=5m \
  CMD /scripts/healthcheck.sh || exit 1
