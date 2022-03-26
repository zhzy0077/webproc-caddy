FROM caddy:2-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/dnspod

ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v0.4.0/webproc_0.4.0_linux_amd64.gz

RUN apk update \
	&& apk add ca-certificates \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/bin/webproc \
	&& chmod +x /usr/bin/webproc 

FROM caddy:2

COPY --from=builder /usr/bin/webproc /usr/bin/webproc
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

COPY Caddyfile /etc/Caddyfile

ENTRYPOINT ["webproc", "--configuration-file", "/etc/Caddyfile", "--on-save", "ignore", "--","caddy"]
CMD ["run", "--config", "/etc/Caddyfile", "--adapter", "caddyfile", "--watch"]