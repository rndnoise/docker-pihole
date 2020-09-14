FROM debian:buster-slim

# Build time environment
ARG TARGETPLATFORM
ARG S6_VERSION=v1.22.1.0
ARG PIHOLE_CORE_VERSION=v5.1.2
ARG PIHOLE_WEB_VERSION=v5.1.1
ARG PIHOLE_FTL_VERSION=v5.2
ARG DEBIAN_FRONTEND=noninteractive
ARG PIHOLE_SKIP_OS_CHECK=true

RUN apt-get update
RUN apt-get install --no-install-recommends -y \
      curl procps ca-certificates netcat-openbsd

# curl in armhf-buster's image has SSL issues. Running c_rehash fixes it.
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=923479
RUN c_rehash

COPY Dockerfile.sh /
COPY root/         /
RUN touch          /.dockerenv

# Hard to track down issue: COPY uses the file permissions from the working dir,
# which ought to be 0755... but when they're 0700, we see strange errors about
# hostname lookups failing. Git only tracks the executable bit, not read/write.
RUN chmod 755 /etc /usr /usr/bin /usr/bin/*

# Runtime container environment
ENV S6_LOGGING=0                        \
    S6_KEEP_ENV=1                       \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2      \
    PIHOLE_DNS_USER=pihole              \
    PATH=/opt/pihole:${PATH}

RUN /Dockerfile.sh && \
    rm -rf /Dockerfile.sh /var/cache/apt/archives /var/lib/apt/lists/*

EXPOSE  53/udp
EXPOSE  53/tcp
EXPOSE  80/tcp
EXPOSE 443/tcp

SHELL       ["/bin/bash", "-c"]
WORKDIR     /
ENTRYPOINT  [ "/s6-init" ]
HEALTHCHECK CMD dig +norecurse +retry=0 @127.0.0.1 localhost
