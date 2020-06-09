FROM lsiobase/alpine:3.12
ARG RELEASE

COPY s6/ /
RUN \
    bash /setup/setup.sh && \
    rm -R /setup

VOLUME ["/config"]

EXPOSE 80

ENV MYSQL_DATABASE="webtrees" \
    MYSQL_USER="webtrees" \
    MYSQL_PASSWORD="YouShouldveChangedThis"
LABEL "lostlakkris.service"="webtrees"
