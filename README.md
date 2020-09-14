# Docker Pi-hole

<p align="center">
<a href="https://pi-hole.net"><img src="https://pi-hole.github.io/graphics/Vortex/Vortex_with_text.png" width="150" height="255" alt="Pi-hole"></a><br/>
</p>


![build status](      https://github.com/rndnoise/docker-pi-hole/workflows/build/badge.svg)
![release version](   https://img.shields.io/github/v/release/rndnoise/docker-pihole.svg?maxAge=604800)
![release date](      https://img.shields.io/github/release-date/rndnoise/docker-pihole.svg?maxAge=604800)
![unreleased commits](https://img.shields.io/github/commits-since/rndnoise/docker-pihole/latest.svg?maxAge=604800)

## Overview

A [Docker project](https://www.docker.com/what-docker) to make a lightweight x86 or ARM container with [Pi-hole](https://pi-hole.net/) functinnality.

## Quick start

Here's an example `docker-compose.yml`:

```yaml
version: "3"

services:
  pihole:
    container_name: pihole
    image: example/pihole:latest
    ports:
      - "80:80/tcp"
      - "53:53/tcp"
      - "53:53/udp"
    restart: unless-stopped
    environment:
      TZ: America/Chicago
      PUID: 999
      PGID: 999
      PIHOLE_IPV4_ADDRESS: "0.0.0.0"
      PIHOLE_IPV6_ADDRESS: "::"
      PIHOLE_WEB_PASSWORD: "the password is password"
      PIHOLE_WEB_HOSTNAME: "pi.hole"
      PIHOLE_DNS_UPSTREAM_1: 1.1.1.1
      PIHOLE_DNS_UPSTREAM_2: 1.0.0.1
      PIHOLE_DNS_UPSTREAM_3: 8.8.8.8
      PIHOLE_DNS_UPSTREAM_4: 9.9.9.9
    volumes:
      - ./pihole/var-log:/var/log
      - ./pihole/etc-pihole:/etc/pihole
      - ./pihole/etc-dnsmasq.d:/etc/dnsmasq.d
```

Here's an equivalent `docker run` command:

```sh
docker run \
  --detach \
  --name pihole \
  --restart=unless-stopped \
  --publish 53:53/udp \
  --publish 53:53/tcp \
  --publish 80:80/tcp \
  --env "TZ=America/Chicago" \
  --env "PUID=999" \
  --env "PGID=999" \
  --env "PIHOLE_IPV4_ADDRESS=0.0.0.0" \
  --env "PIHOLE_IPV6_ADDRESS=::" \
  --env "PIHOLE_WEB_PASSWORD=the password is password" \
  --env "PIHOLE_WEB_HOSTNAME=pi.hole" \
  --env "PIHOLE_DNS_UPSTREAM_1=1.1.1.1" \
  --env "PIHOLE_DNS_UPSTREAM_2=1.0.0.1" \
  --env "PIHOLE_DNS_UPSTREAM_3=8.8.8.8" \
  --env "PIHOLE_DNS_UPSTREAM_4=9.9.9.9" \
  --volume "$(pwd)/pihole/var-log:/var/log" \
  --volume "$(pwd)/pihole/etc-pihole:/etc/pihole" \
  --volume "$(pwd)/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
  example/pihole:latest
```

## Environment variables

| Environment variable name     | Default | Values      | Description |
| ----------------------------- | ------- | ----------- | ----------- |
| `PIHOLE_ADMIN_EMAIL`            |         |             | Set an administrative contact address on the block page
| `PIHOLE_DNS_BLOCKING_MODE`      | `NULL`    | [See docs](https://docs.pi-hole.net/ftldns/blockingmode/)    | Method used to block queries
| `PIHOLE_DNS_BOGUS_PRIV`         | `true`    | `true`, `false` | Forward reverse lookups on private ranges to upstream servers
| `PIHOLE_DNS_CNAME_INSPECT`      | `true`    | `true`, `false` | Enable or disable deep CNAME inspection. See [PR #663](https://github.com/pi-hole/FTL/pull/663)
| `PIHOLE_DNS_DNSSEC`             | `false`   | `true`, `false` | Enable or disable DNSSEC
| `PIHOLE_DNS_FQDN_REQUIRED`      | `true`    | `true`, `false` | Forward queries on non-FQDNs to upstream servers
| `PIHOLE_DNS_IGNORE_LOCALHOST`   | `false`   | `true`, `false` | Ignore queries originating from the local machine
| `PIHOLE_DNS_LAN_DOMAIN`         |         |             | When LAN forwarding is enabled, forward queries for this domain to upstream LAN DNS server
| `PIHOLE_DNS_LAN_ENABLE`         | `false`   | `true`, `false` | Enable or disable forwarding queries for LAN to a separate DNS server
| `PIHOLE_DNS_LAN_NETWORK`        |         | IPv4/6 CIDR | When LAN forwarding is enabled, forward reverse queries for this network range to upstream LAN DNS server
| `PIHOLE_DNS_LAN_UPSTREAM`       |         |             | When LAN forwarding is enabled, use this DNS server to resolve LAN queries
| `PIHOLE_DNS_PRIVACY_LVL`        | `0`       | [See docs](https://docs.pi-hole.net/ftldns/privacylevels/)    | Specifies level of detail given in Pi-hole statistics.
| `PIHOLE_DNS_UPSTREAM_1`*        |         | IPv4/6 addr | Primary upstream DNS server
| `PIHOLE_DNS_UPSTREAM_2`         |         | IPv4/6 addr | Secondary upstream DNS server
| `PIHOLE_DNS_UPSTREAM_3`         |         | IPv4/6 addr | Tertiary upstream DNS server
| `PIHOLE_DNS_UPSTREAM_4`         |         | IPv4/6 addr | Quaternary upstream DNS server
| `PIHOLE_DNS_USER`               | `pihole`  |             | User which runs `pihole-FTL` (can be `root`)
| `PIHOLE_IPV4_ADDRESS`           | `0.0.0.0` | `auto`, IPv4 addr | Your Pi-hole's address, used to redirect/block requests
| `PIHOLE_IPV6_ADDRESS`           | `::`      | `auto`, IPv6 addr | Your Pi-hole's address, used to redirect/block requests
| `PIHOLE_LISTEN`                 | `all`     | `all`, `iface`, `local` | Listen to all `local` subnets, `all` networks (including the Internet), or a specified `iface`
| `PIHOLE_INTERFACE`              |         |             | When `PIHOLE_LISTEN` is `iface`, specifies the interface used to listen for DNS queries and HTTP requests
| `PIHOLE_TEMPERATURE_UNIT`       | `F`       | `F`, `C`, `K`     |
| `PIHOLE_WEB_HOSTNAME`           | `hostname -f` |         | The hostname used to access the Pi-hole admin page
| `PIHOLE_WEB_PASSWORD`           | randomized |          | The password required to access the Pi-hole admin page. See `pihole logs pihole` to find the randomized password
| `PIHOLE_WEB_PASSWORD_FILE`      |         |             | Filename containing password, will override `PIHOLE_PASSWORD` if it's set.
| `PIHOLE_WEB_PORT`               | `80`      |             | Which port the admin page should listen on
| `PIHOLE_WEB_UI`                 | `boxed`   | `boxed`, `traditional` | | Which layout is used for the admin page

Required environment variables (which do not have default values) are indicated by `*`

## Tips and tricks

...

## Docker tags and versioning

...

## Upgrading

...

## Running DHCP from Docker Pi-hole

This docker image doesn't support configuring FTLDNS as a DHCP server. Instead, you can either use `PIHOLE_DNS_LAN_...` configuration to forward LAN traffic to your DHCP server/router, or write a script to export data from your DHCP server to a host file and drop a config file in `/etc/dnsmasq.d/` to tell FTLDNS about that file. Changes to that file will auttomatically be detected without restarting FTLDNS.

```
local=/lan/                   # answer queries from this domain using host files
hostsdir=/etc/dnsmasq.d/lan   # files in thtis directory will be used as host files
```
## Upgrade notices

### Docker Pi-hole v5.1.2

This version was forked from [pi-hole/docker-pi-hole](https://github.com/pi-hole/docker-pi-hole/tree/v5.1.2) and then largely rewritten. The build has been rewritten using a single `Dockerfile` and one installation script, `Dockerfile.sh`. Multiarch images are built using `docker buildx` via GitHub actions and automatically published to Docker Hub. The startup shell scripts that configured Pi-hole have been replaced with a single Perl script. 
