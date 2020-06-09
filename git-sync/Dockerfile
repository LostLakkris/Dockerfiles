FROM lsiobase/alpine:3.12

COPY s6/ /
RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main bash git tini openssh jq curl

VOLUME ["/data", "/update-hooks"]

ENV SET_SERVICE="git-sync"
LABEL "lostlakkris.service"="git-sync"

