# Pulled from https://github.com/willfarrell/docker-autoheal.git, to self-build multi-arch because willfarrell's appears broken at the moment
FROM alpine:latest
RUN apk add --no-cache curl jq

COPY autoheal.source/docker-entrypoint /
ENTRYPOINT ["/docker-entrypoint"]

HEALTHCHECK --interval=5s CMD /docker-entrypoint healthcheck

CMD ["autoheal"]