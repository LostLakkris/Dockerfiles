ARG RELEASE
FROM linuxserver/nzbget:${RELEASE}
COPY lakkris.s6/ /
ENV SET_SERVICE="nzbget" \
    SET_PORT="6789"
LABEL "lostlakkris.service"="nzbget"

HEALTHCHECK --interval=30s --timeout=3s --start-period=4m \
  CMD /scripts/healthcheck.sh || exit 1
