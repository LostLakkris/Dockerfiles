FROM lsiobase/alpine:3.11

COPY lakkris.s6/ /
COPY git-sync.s6/ /
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main bash git tini openssh jq curl

VOLUME ["/data", "/update-hooks"]

ENV SET_SERVICE="git-sync"
LABEL "lostlakkris.service"="git-sync"

#ENTRYPOINT [ "tini", "-g", "--" ]
#CMD [ "/opt/bin/git-sync.sh" ] ## Replaced with s6 service file
