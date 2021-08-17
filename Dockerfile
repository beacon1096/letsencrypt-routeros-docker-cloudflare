FROM certbot/dns-cloudflare:arm64v8-latest

RUN apk add --no-cache bash openssh-client