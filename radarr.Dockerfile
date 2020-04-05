FROM linuxserver/radarr:latest
COPY lakkris.s6/ /
ENV SET_SERVICE="radarr" \
    SET_PORT="7878" \
    LOSTLAKKRIS_CONTENT="movies"
LABEL "lostlakkris.service"="radarr" \
      "lostlakkris.content"="movies"

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /scripts/healthcheck.sh || exit 1
