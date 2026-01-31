FROM alpine:3.19

RUN apk add --no-cache curl netcat-openbsd

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
