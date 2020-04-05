FROM linuxserver/lidarr:latest
COPY lakkris.s6/ /
ENV SET_SERVICE="lidarr" \
    SET_PORT="8686" \
    LOSTLAKKRIS_CONTENT="music"
LABEL "lostlakkris.service"="lidarr" \
      "lostlakkris.content"="music"

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /scripts/healthcheck.sh || exit 1
