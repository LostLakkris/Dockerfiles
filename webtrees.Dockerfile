FROM lsiobase/alpine:3.11
ARG RELEASE

COPY lakkris.s6/ /
COPY mariadb.s6/ /
COPY webtrees.s6/ /
RUN \
    bash /setup/setup.sh && \
    rm -R /setup

VOLUME ["/config"]

EXPOSE 80

ENV SET_SERVICE="webtrees" \
    SET_PORT="80" \
    MYSQL_DATABASE="webtrees" \
    MYSQL_USER="webtrees" \
    MYSQL_PASSWORD="YouShouldveChangedThis"
LABEL "lostlakkris.service"="webtrees"

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /scripts/healthcheck.sh || exit 1
