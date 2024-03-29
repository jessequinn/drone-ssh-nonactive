FROM alpine:3.4
MAINTAINER Jesse Quinn <me@jessequinn.info>

RUN apk add --no-cache ca-certificates bash openssh-client
COPY drone.sh /usr/local/

ENTRYPOINT ["/usr/local/drone.sh"]
