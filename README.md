[issues]: https://github.com/kladiv/docker-nsq/issues
[Pulse Secure]: https://www.pulsesecure.net/trynow/client-download/
[openconnect proxy]: https://github.com/cernekee/ocproxy.git
[Docker Hub]: https://hub.docker.com/r/claudiomastrapasqua/docker-nsq/
[jamgocoop/pulsesecure-vpn]: https://hub.docker.com/r/jamgocoop/pulsesecure-vpn/


## docker-pulsevpn

Custom docker image for [Pulse Secure].

This image is on [Docker Hub] and is based on source docker image [jamgocoop/pulsesecure-vpn] and integrate/enable the [openconnect proxy] feature.

### Getting the image

To get the image download it via:

`docker pull claudiomastrapasqua/docker-pulsevpn`

### How to use this image

**Connect using User/Password**:

```bash
$ docker run --name \
        pulsevpn \
        -e "VPN_URL=<vpn_connect_url>" \
        -e "VPN_USER=<user>" \
        -e "VPN_PASSWORD=<password>" \
        -e "OPENCONNECT_OPTIONS=<openconnect_extra_options>" \
        --privileged=true \
        -d claudiomastrapasqua/docker-pulsevpn
```

**Connect using a certificate**:

```bash
docker run --name \
        pulsevpn \
        -e "VPN_URL=<vpn_connect_url>" \
        -e "VPN_USER=<user>" \
        -e "VPN_PASSWORD=<password>" \
        -e "OPENCONNECT_OPTIONS=<openconnect_extra_options>" \
        -v /full/path/<user>.pem:/root/<user>.pem:ro \
        --privileged=true \
        -d claudiomastrapasqua/docker-pulsevpn
```

>**Bad server certificate:**
>
>If the connect server has and insecure or self signed certificate you must follow a few more steps. The openconnect option **--no-cert-check** has been removed from the current version of openconnect, so we must obtain the server's cert fingerprint and pass it to openconnect.
>
>`$ docker run --rm -ti claudiomastrapasqua/docker-pulsevpn openconnect <vpn_connect_url>`
>
>You will obtain something like:
>
>```bash
>POST https://example.com/xyz
>Connected to xxx.xxx.xxx.xxx:443
>SSL negotiation with example.com
>Server certificate verify failed: signer not found
>```
>Certificate from VPN server "example.com" failed verification.<br/>
>Reason: signer not found<br/>
>To trust this server in future, perhaps add this to your command line:<br/>
>&nbsp;&nbsp;--servercert pin-sha256:lERGk61FITjzyKHcJ89xpc6aDwtRkOPAU0jdnUqzW2s= <br/>
>Enter 'yes' to accept, 'no' to abort; anything else to view:
>```
>	
>Answer **no** and copy the printed option: `--servercert pin->sha256:lERGk61FITjzyKHcJ89xpc6aDwtRkOPAU0jdnUqzW2s=`.
>	
>Now you can pass the **--servertcert** option to the final docker execution to avoid the warning and user interaction.
>
>```bash
>$ docker run --name \
>	pulsevpn \
>	-e "VPN_URL=<vpn_connect_url>" \
>	-e "VPN_USER=<user>" \
>	-e "VPN_PASSWORD=<password>" \
>	-e "OPENCONNECT_OPTIONS=--servercert pin-sha256:lERGk61FITjzyKHcJ89xpc6aDwtRkOPAU0jdnUqzW2s=" \
>	-v /full/path/<user>.pem:/root/<user>.pem:ro \
>	--privileged=true \
>	-d claudiomastrapasqua/docker-pulsevpn
>```

**Enable OpenConnect Proxy (ocproxy)**:

To enable ocproxy openconnect feature, pass OCPROXY_ENABLE=1 (*default disabled* -> 0) and OCPROXY_PORT environment variable during docker run:

```bash
$ docker run --name \
	pulsevpn \
	-e "VPN_URL=<vpn_connect_url>" \
	-e "VPN_USER=<user>" \
	-e "VPN_PASSWORD=<password>" \
	-e "OPENCONNECT_OPTIONS=--servercert pin-sha256:lERGk61FITjzyKHcJ89xpc6aDwtRkOPAU0jdnUqzW2s=" \
	-e "OCPROXY_ENABLE=1"
	--privileged=true \
	-d claudiomastrapasqua/docker-pulsevpn
```

If OCPROXY_PORT variable is not specified, default port is *2222*.

You can expose OCPROXY_PORT only to localhost using `-p 127.0.0.1:2222:2222` or normally as `-p 2222:2222` (suggested only for trusted network environment)

### Route connections via docker-pulsevpn container

Once started you can route subnets from docker host via docker-pulsevpn container. You can create a *route_add.sh* bash script like below (to run as root user):

```bash
#! /bin/bash
PULSESECURE_DOCKER_IP="`docker inspect --format '{{ .NetworkSettings.IPAddress }}' pulsevpn`"
if [ -z "${PULSESECURE_DOCKER_IP}" ]; then
  echo >&2 'error: missing PULSESECURE_DOCKER_IP, is pulsevpn docker running?'
  exit 1;
fi
# /24 subnets example
route add -net a.b.c.0 netmask 255.255.255.0 gw ${PULSESECURE_DOCKER_IP}
route add -net x.y.z.0 netmask 255.255.255.0 gw ${PULSESECURE_DOCKER_IP}
...
```

### Remote SSH access via docker-pulsevpn container

You can connect via SSH to a remote server (reachable only via VPN) using ssh command below:

```bash
PULSESECURE_DOCKER_IP="`docker inspect --format '{{ .NetworkSettings.IPAddress }}' pulsevpn`"
ssh -o ProxyCommand="nc -X 5 -x ${PULSESECURE_DOCKER_IP}:2222 %h %p" <username>@<remote_server_via_vpn>
```

If you have exposed OCPROXY_PORT during docker run command, then you can use *127.0.0.1*:

```bash
ssh -o ProxyCommand="nc -X 5 -x 127.0.0.1:2222 %h %p" <username>@<remote_server_via_vpn>
```

SSH ProxyCommand uses the netcat SOCKS5 proxy connection feature.

### Deploy stack via docker-compose file (3-nodes example)

*Requirements: Docker Engine 17.12.0+*

```
TBD
```

### Logging

You can read container/service logs via commands:

`$ docker logs -f <container_name or container_id>`

or

`$ docker service logs -f <service_name or service_id>`

### Support

Open [issues] on GitHub
