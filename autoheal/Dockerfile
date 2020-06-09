# Derived from https://github.com/willfarrell/docker-autoheal.git for multiarch building
FROM alpine:latest
RUN apk add --no-cache curl jq

COPY docker-entrypoint /

ENTRYPOINT ["/docker-entrypoint"]
CMD ["autoheal"]

HEALTHCHECK --interval=5s CMD /docker-entrypoint healthcheck
