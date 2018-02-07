# OroCRM docker

Docker compose project for standalone OroCRM

Featuring a full nginx webserver with letsencrypt support

# Running

```
git clone https://github.com/bebehei/orocrm-docker
cd orocrm-docker
cp config.tpl config
$EDITOR config
docker-compose up -d
```

## Executing commands

If you need manage the installation and have to execute some oro commands, you can access the console via:

```
docker-compose exec web oro-console <command>
```

Where `<command>` could be something like `help`, which will give a list of available commands.

# Installation

Do it via the command line:

```
docker-compose exec web \
  oro-console oro:install --env=prod \
     --application-url=https://customers.are-not-relev.ant \
     --user-name=bogusadmin \
     --user-email=admin@are-not-relev.ant \
     --user-firstname=Bogus \
     --user-lastname=Admin \
     --user-password=null \
     --sample-data=true
```

**IMPORTANT: Set the `ORO_INSTALLED` variable after installation to something, which evaluates to `true` in PHP. At best, use the output of `php -r 'print(date("c"). "\n");'`, as this is the same, what OroCRM would set it to.**

To get a full list of supported options, consult `docker-compose exec web oro-console help oro:install`.

As an alternative, you also could just go to the website and run through the install instructions there.

## Configuration

### SSL via Letsencrypt

Set the parameter `LETSENCRYPT` environment variable to `1` and mount the a volume under `/etc/letsencrypt`.

### SSL via supplied certificate

Mount the certificate and the private key as a volume under:
  - `/certs/ssl.key`
  - `/certs/ssl.crt`
