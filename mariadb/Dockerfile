FROM lsiobase/alpine:3.12

COPY s6/ /
RUN \
    bash /setup/setup.sh && \
    rm -R /setup

VOLUME ["/config"]

EXPOSE 3306

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /scripts/mariadb-healthcheck.sh || exit 1
