FROM lsiobase/alpine:3.11

COPY lakkris.s6/ /
COPY mariadb.s6/ /
COPY shinobi.s6/ /
RUN \
    bash /setup/setup.sh && \
    rm -R /setup

VOLUME ["/opt/shinobi/videos", "/config"]

EXPOSE 8080

ENV SET_SERVICE="shinobi" \
    SET_PORT="8080" \
    MYSQL_PRESEED="/tmp/shinobi.sql"
LABEL "lostlakkris.service"="shinobi"

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /scripts/healthcheck.sh || exit 1
