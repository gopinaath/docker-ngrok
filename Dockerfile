FROM alpine:3.12
MAINTAINER Werner Beroux <werner@beroux.com>

# https://github.com/sgerrand/alpine-pkg-glibc
ARG GLIBC_VERSION=2.31-r0

RUN set -x \
 && apk add --no-cache -t .deps ca-certificates \
    # Install glibc on Alpine (required by docker-compose)
    # See also https://github.com/gliderlabs/docker-alpine/issues/11
 && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && apk add glibc-${GLIBC_VERSION}.apk \
 && apk add --no-cache bash \
 && apk add --no-cache sudo  \
 && rm glibc-${GLIBC_VERSION}.apk \
 && apk del --purge .deps

RUN set -x \
    # Install ngrok (latest official stable from https://ngrok.com/download).
 && apk add --no-cache curl \
 && curl -Lo /ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip \
 && echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel \
    # Create non-root user.
 && adduser --disabled-password --uid 12345 -h /home/ngrok ngrok \
 && adduser ngrok wheel

# Add config script.
COPY --chown=ngrok ngrok.yml /home/ngrok/.ngrok2/
COPY entrypoint.sh /

USER root
ENV USER=root

# Basic sanity check.
RUN ngrok --version

# EXPOSE 4040 9090
EXPOSE 4040

CMD ["/entrypoint.sh"]
