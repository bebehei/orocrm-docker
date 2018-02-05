# OroCRM docker

Docker compose project for standalone OroCRM

Featuring a full nginx webserver with letsencrypt support

# Running

```
git clone https://github.com/bebehei/orocrm-docker
cd orocrm-docker
cp env_global.tpl env_global
$EDITOR env_global
docker-compose up -d
```

# Installation

TODO

## Configuration

### SSL via Letsencrypt

Set the parameter `LETSENCRYPT` environment variable to `1` and mount the a volume under `/etc/letsencrypt`.

### SSL via supplied certificate

Mount the certificate and the private key as a volume under:
  - `/certs/ssl.key`
  - `/certs/ssl.crt`
