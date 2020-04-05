FROM linuxserver/sonarr:latest
COPY lakkris.s6/ /
ENV SET_SERVICE="sonarr" \
    SET_PORT="8989" \
    LOSTLAKKRIS_CONTENT="tv"
LABEL "lostlakkris.service"="sonarr" \
      "lostlakkris.content"="tv"

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /scripts/healthcheck.sh || exit 1
