# HAproxy

This is a Quantum Safe Crypto (QSC)-enabled demonstration build-and-execution environment for [HAproxy](https://github.com/haproxy/haproxy). 

## Motivation

In order to demonstrate the utility of QSC algorithms the [Open Quantum Safe (OQS) project](https://openquantumsafe.org) provides a collection of all QSC algoritms that are part of the [NIST competition](https://csrc.nist.gov/Projects/Post-Quantum-Cryptography) within the [liboqs](https://github.com/open-quantum-safe/liboqs) library. At application level, integrations of [OpenSSL](https://github.com/open-quantum-safe/openssl) and [curl](https://github.com/curl/curl) exist to document how well QSC algorithms fit into the existing open source security application landscape.

The integration in this folder extends this work with a QSC-enabled [HAproxy](https://github.com/haproxy/haproxy) such as to permit further application-level experimentation utilizing real-world load-balancing HTTP(s) servers.

To further ease deployment in non-QSC-enabled settings, this project also contains an Alpine-based appliance ("client-side proxy") meant to operate as an application-level, QSC-enabled TLS VPN (virtual private network) with haproxy operating on both ends of the VPN tunnel.

## Platform

The scripts in this folder are geared for Ubuntu and Alpine Linux distributions and have been tested on x86_64 environments.


## Setup

The scripts in this folder consist of two pieces: utility scripts (in the `scripts` folder) and all components for Docker images bringing all components together in one coherent setup:

### Components

The resultant master Docker image (built when executing `scripts/dockerbuild.sh`) comprises the following QSC-enabled components (all installed in `/opt/oqssa`):

- liboqs: All NIST-round 2 competition algorithms
- openssl: QSC-enabled OpenSSL 1.1.1 library and utility applications
- curl: QSC-enabled curl
- haproxy: QSC-enabled HAproxy

In addition, the image contains a simple (non-QSC) HTTP server, [lighttpd](https://www.lighttpd.net) serving as a (test) backend to the HAproxy.

### Architecture

These components permit the following setup:

curl ->(QSC-SSL)-> haproxy ->(plain HTTP)-> lighttpd

In words: The HAproxy is configured on the frontend to provide a QSC-enabled TLS entry port and performs plain HTTP load balancing towards lighttpd as backend.

## Quick start

### Short form

`docker run -p 4443:4443 -e BACKEND=<backend-address:port> -t openqsafe/haproxy-appliance` starts a QSC-enabled HAproxy on port 4443 of the local machine acting as reverse proxy towards the (plain http) backend.

If you have an OQS-enabled SDK or applications, you can connect to this as usual, e.g., via `curl https://HAPROXY-ADDRESS:4443`.

If you do not have that, you can start a forward proxy with this command 

`docker run -p 8080:8080 -e DISABLE_CERT_CHECK=1 -t openqsafe/haproxy-local-appliance HAPROXY-ADDRESS:4443` provides a plain interface to the above at `http://localhost:8080'.

This sets up a transparent, application level QSC-protected tunnel between the two HAproxy instances that can be accessed with any plain HTTP tooling or browser. For more secure and realistic setups, read on.

### Some more details

If provided no arguments, the main docker image configures all components and creates all required persistent HAproxy frontend PKI artifacts in an ephemeral manner: CA (key and certificate), server (key and certificate). The utility script for this is `scripts/run.sh`. The resultant HAproxy is accessible at the exposed port 4443.

If one wants to interact with all components on a command line within the running image, the utility script `scripts/run-bash.sh` should be run: All components are started by executing `startup.sh`, may be checked to be running (`ps -ags`) and can be exercized with the command `curl --cacert root/CA.crt https://my.ha.proxy`.

**Hint**: The startup scripts can take the names of the OQS KEM and OQS signature algorithm as parameters. The former defines the cryptographic cipher used, the latter the signature type of the certificates. By default these values are `kyber512` and `dilithium4`, respectively.

All default settings for running the haproxy are encoded in the `haproxy.cfg` configuration file (in `/opt/haproxy`).

### Docker hub availability

The docker image containing all components as described here is available at Dockerhub under the name `openqsafe/haproxy-ubuntu`.

### Building

The docker image providing the core functionality described can be build by running the script `scripts/dockerbuild.sh`. The script has been validated to run OK under Linux and OSX with docker [installed](https://docs.docker.com/install/).

## More realistic setup: Separating CA and HAproxy

For anyone interested in running an HAproxy for a longer period and utilizing a more realistic setup with an QSC-enabled certificate authority (CA) the following utility scripts permit doing this:

1. `scripts/create-oqsca.sh`: Creates self-signed, password-protected QSC key/cert pair acting as a root CA for later steps. The QSC algorithm chosen can be changed from the default setting (`dilithium4`) with the parameter `-s`.
2. `scripts/gen-server-csr.sh`: Creates QSC key and certificate signing request (CSR) for the server DNS name passed as parameter. The QSC algorithm chosen can be changed from the default setting (`dilithium4`) with the parameter `-s`.
3. `scripts/sign-server-csr.sh`: Signs the CSR created in the second step with the CA key created in the first step.
4. `scripts/haproxy-run.sh`: Start the docker image on the host named in step 2 above.

## Further configuration options

### Utility scripts

All shell scripts have the same optional two parameters:

- `--sig` (or `-s`): Signature algorithm: Choose any listed [here](https://github.com/open-quantum-safe/openssl#authentication). Default is `dilithium4`.
- `--kem` (or `-k`): KEM algorithm: Choose any listed [here](https://github.com/open-quantum-safe/openssl#key-exchange). Default is `kyber512`.

By way of example, the command `./scripts/run-bash.sh -s qteslapiii ` will create a docker instance running a QSC haproxy environment using QTeslaIII signatures with a Kyber512 KEM.

### HAproxy

The most relevant of the many [HAproxy configuration options](https://cbonte.github.io/haproxy-dconv/2.0/configuration.html) for the purpose of this setup is the **frontend** *bind* option: Here, the `curves` parameter defines the QSC key encapsulation mechanism (KEM) actually operated by the haproxy instance. By default, this is set to `kyber512` but can be changed to any of the presently supported KEMs listed [here](https://github.com/open-quantum-safe/openssl#key-exchange).

### Demonstration environment variables

Two environment variables are available for changing the information displayed by the system during operation:

#### OQSINTERNALS

Setting this variable (e.g., by `export OQSINTERNALS=1`) causes the system to display the OQS KEM and OQS signature algorithm to be displayed whenever activated. By default this information is not displayed.

#### OQSWARNINGDISABLE

Setting this variable (e.g., by `export OQSWARNINGDISABLE=1`) causes the system to no longer display the non-productiveness warning.

## HAproxy Appliance ("server-side proxy")

The build script `scripts/dockerbuild.sh` also creates an appliance-style, OQS-enabled HAproxy in reverse proxy configuration as another docker image. This docker image only contains the basics required to run HAproxy in a QSC configuration. It does not contain `curl` as a frontend nor `lighttpd` as backend. It can be started with all the same parameters introduced above via the script `scripts/appliance-run.sh`. This script takes as optional parameter the address of the backend this HAproxy shall connect to. Default backend is at `127.0.0.1:82`.

**Note**: This appliance has a plain HTTP *backend* and an OQS-enabled *frontend*. By properly changing the configuration of `haproxy.cfg` the backend configuration can be changed to a TLS-protected one as well, of course. In the docker image, setting the environment variable 'BACKEND' (see [quick start example](#short-form)) facilitates this without the need to change the docker image.

## Local Appliance ("client-side proxy")

The folder `alpine` contains Dockerfiles and related scripts to create a small, OQS-enabled (forward) HAproxy appliance. The purpose of this local appliance is to shield client software from (having to use) QSC-enabled software via a simple HTTP interface. As such, it has an OQS-**backend** and a plain HTTP frontend. By switching between the two startup scripts provided, this HAproxy alpine appliance can be configured to run in either server-side or client-side proxy mode. 

### Architecture

This new component permits the following setup:

Application (curl, web browser, etc) ->(plain HTTP)-> client-side haproxy ->(QSC-SSL)-> (server-side) haproxy ->(plain HTTP)-> lighttpd

In words: A second HAproxy is configured as a local, application-level VPN tunnel endpoint that any HTTP client application can connect to. It connects in turn to the first HAproxy that is configured on the frontend to provide a QSC-enabled TLS entry port and performs plain HTTP load balancing towards lighttpd as backend.

### Building

Creating the appliance is a two-step process (Docker "multistage build") executed by the script `dockerbuild.sh` in the `alpine` folder:

- Compile-Install: All components introduced above are build and installed to a local folder (`opt`)
- Build: Only the resultant libraries and executables are loaded into a minimal Alpine image


### Parameters

By default, the appliance connects to an OQS-enabled TLS server running at the DNS name `my.ha.proxy`. This name can be changed to a server address of choice by passing a parameter to the startup script `scripts/localapp-run.sh`.

By default, the appliance is accessible at the localhost port 8082. This port can be changed by adapting the relevant port number in the script itself.

## Putting it all together in a single-host demo environment

Pulling all the steps above together, the script `alpine/network-run.sh` configures all components to establish and exercise all components in the architecture depicted above: 

- QSC-CA and -haproxy keys and certificates are generated
- A docker network is set up into which the following two images are deployed:
- QSC-enabled HAproxy acting as a QSC-TLS enabled load balancer to a lighttpd instance running in the same image
- QSC-enabled minimal HAproxy appliance acting as a local plain HTTP communications endpoint and communicating via QSC-secured TLS with the above HAproxy instance 

**Hint**: The `alpine/network-run.sh` script can be called with a parameter to cause a cleanup of a previous run (`alpine/network-run.sh --clean`). All other parameters introduced above and controlling the actual OQS algorithms can also be used. Also, the local port can be set (`--port`) at which the appliance is listening for HTTP traffic to be forwarded. **The port cannot be in the privileged port range <1024 as the image does not run with superuser/root privileges**


## FAQ

### I'm getting an "SSL handshake failure" when starting the local proxy: What's wrong?

Most likely you have not configured the correct (QSC-)root CA to validate the (QSC-protected) authenticity (signature) of the HAproxy you want to connect to.

Solution: Either follow the steps [above to establish a real mini CA and certificates](#more-realistic-setup-separating-ca-and-haproxy) or disable checking the server certificate by the haproxy config option `verify none`, exposed to the docker image by the environment variable `DISABLE_CERT_CHECK`.

### I'm annoyed by the constant 'non-productiveness' warnings. Can they be switched off?

Yes, set the environment variable `OQSWARNINGDISABLE` to a non-empty value.

### Which ports do the appliances run at and expose?

By default, the client-side proxy operates ports 8080 and 4443 for plain HTTP and encrypted HTTPS traffic, respectively.

By default, the server-side proxy operates ports 8087 and 4443 for plain HTTP and encrypted HTTPS traffic, respectively.

For each proxy docker image, the actual ports exposed to the outside world can be set as usual with the `-p` option when executing `docker run`.

###### Footnote

For comparison, the folder `non-oqs` contains all prerequisites to set up an equivalent, non-OQS-enabled HAproxy --- also in a Docker image, also using Ubuntu 19 as the base OS, also using OpenSSL 1.1.1 and TLS 1.3 as the communications parameters, also featuring lighttpd as a backend with the same basic testing targets (`/` for GET and `/cgi-bin/upload.cgi` for POST). This way, one can run and exercize HAproxy images that are QSC-enabled and containing only classic cryptography side-by-side on the same infrastructure for comparative measurements between QSC-enabled HAproxy and HAproxy only running classic cryptography.
