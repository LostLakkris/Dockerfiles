FROM lsiobase/alpine:3.12

COPY s6/ /
RUN \
    bash /setup/mariadb.sh && \
    bash /setup/shinobi.sh && \
    rm -R /setup

VOLUME ["/opt/shinobi/videos", "/config"]

EXPOSE 8080

ENV MYSQL_PRESEED="/tmp/shinobi.sql"
LABEL "lostlakkris.service"="shinobi"
