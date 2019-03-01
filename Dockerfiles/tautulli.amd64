FROM linuxserver/tautulli:latest
ENV LAKKRIS_SERVICE="tautulli" \
    LAKKRIS_ICON="plugins/images/tabs/tautulli.png" \
    LAKKRIS_PORT="8181" \
    LAKKRIS_CONFIGFILE="/config/config.ini" \
    LAKKRIS_SERVERNAME="lostlakkris"

EXPOSE 7946

COPY bin/serf_0.8.1_amd64 /usr/sbin/serf
COPY bin/jq_1.6_amd64 /usr/sbin/jq
COPY bin/templater /usr/sbin/templater

COPY lakkris/ /
