FROM linuxserver/tautulli:latest
COPY lakkris.s6/ /
RUN pip install --no-cache-dir -U crudini
ENV SET_SERVICE="tautulli"
LABEL "lostlakkris.service"="tautulli"

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /scripts/healthcheck.sh || exit 1
