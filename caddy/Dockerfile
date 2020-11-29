ARG RELEASE
FROM caddy:${RELEASE}-builder AS builder

RUN xcaddy build \
    --with github.com/ss098/certmagic-s3

FROM caddy:${RELEASE}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
