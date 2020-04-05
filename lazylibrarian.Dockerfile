FROM linuxserver/lazylibrarian:latest
COPY lakkris.s6/ /
RUN apt-get update && \
    apt-get install --no-install-recommends -y crudini && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*
ENV SET_SERVICE="lazylibrarian" \
    SET_PORT="5299" \
    LOSTLAKKRIS_CONTENT="books"
LABEL "lostlakkris.service"="lazylibrarian" \
      "lostlakkris.content"="books"

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /scripts/healthcheck.sh || exit 1
