# HAproxy

This is a Quantum Safe Crypto (QSC)-enabled demonstration build-and-execution environment for [HAproxy](https://github.com/haproxy/haproxy). 

## Motivation

In order to demonstrate the utility of QSC algorithms the [Open Quantum Safe (OQS) project](https://openquantumsafe.org) provides a collection of all QSC algoritms that are part of the [NIST competition](https://csrc.nist.gov/Projects/Post-Quantum-Cryptography) within the [liboqs](https://github.com/open-quantum-safe/liboqs) library. At application level, integrations of [OpenSSL](https://github.com/open-quantum-safe/openssl) and [curl](https://github.com/curl/curl) exist to document how well QSC algorithms fit into the existing open source security application landscape.

The integration in this folder extends this work with a QSC-enabled [HAproxy](https://github.com/haproxy/haproxy) such as to permit further application-level experimentation utilizing real-world load-balancing HTTP(s) servers.

To further ease deployment in non-QSC-enabled settings, this project also contains an Alpine-based appliance meant to operate as an application-level, QSC-enabled TLS VPN (virtual private network) with haproxy operating on both ends of the VPN tunnel.

## Platform

The scripts in this folder are geared for Ubuntu and Alpine Linux distributions and have been tested on x86_64 environments.


## Setup

The scripts in this folder consist of two pieces: utility scripts (in the `scripts` folder) and all components for a Docker image bringing all components together in one coherent setup:

### Components

The resultant Docker image (built when executing `scripts/dockerbuild.sh`) comprises the following QSC-enabled components (all installed in `/opt/oqssa`):

- liboqs: All NIST-round 2 competition algorithms
- openssl: QSC-enabled OpenSSL 1.1.1 library and utility applications
- curl: QSC-enabled curl
- haproxy: QSC-enabled HAproxy

In addition, the image contains a simple (non-QSC) HTTP server, [lighttpd](https://www.lighttpd.net).

### Architecture

These components permit the following setup:

curl ->(QSC-SSL)-> haproxy ->(plain HTTP)-> lighttpd

In words: The HAproxy is configured on the frontend to provide a QSC-enabled TLS entry port and performs plain HTTP load balancing towards lighttpd as backend.

## Quick start

If provided no arguments, the docker image configures all arguments and creates all required persistent HAproxy frontend PKI artifacts in an ephemeral manner: CA (key and certificate), server (key and certificate). The utility script for this is `scripts/run.sh`.

When executed, all components are running (check via `ps -ags`) and can be exercized with the command `curl --cacert root/CA.crt https://my.ha.proxy`.

All default settings for running the haproxy are encoded in the `haproxy.cfg` configuration file (in `/opt/haproxy`).

## More realistic setup

For anyone interested in running an HAproxy for a longer period and utilizing a more realistic setup with an QSC-enabled certificate authority (CA) the following utility scripts permit doing this:

- `scripts/create-oqsca.sh`: Creates self-signed, password-protected QSC key/cert pair. The QSC algorithm chosen can be changed from the default setting (`dilithium4`).
- `scripts/gen-server-csr.sh`: Creates QSC key and certificate signing request (CSR) for the server DNS name passed as parameter. The QSC algorithm chosen can be changed from the default setting (`dilithium3`).
- `scripts/sign-server-csr.sh`: Signs the CSR created in the second step with the CA key created in the first step.

## Further configuration options

### HAproxy

The most relevant of the many [HAproxy configuration options](https://cbonte.github.io/haproxy-dconv/2.0/configuration.html) for the purpose of this setup is the **frontend** *bind* option: Here, the `curves` parameter defines the QSC key encapsulation mechanism (KEM) actually operated by the haproxy instance. By default, this is set to `kyber512` but can be changed to any of the presently supported KEMs listed [here](https://github.com/open-quantum-safe/openssl#key-exchange).

### Demonstration environment variables

Two environment variables are available for changing the information displayed by the system during operation:

#### OQSINTERNALS

Setting this variable (e.g., by `export OQSINTERNALS=1`) causes the system to display the OQS KEM and OQS signature algorithm to be displayed whenever activated. By default this information is not displayed.

#### OQSWARNINGDISABLE

Setting this variable (e.g., by `export OQSWARNINGDISABLE=1`) causes the system to no longer display the non-productiveness warning.

## Appliance

The folder `alpine` contains Dockerfiles and related scripts to create a small, OQS-enabled HAproxy appliance.

### Architecture

This new component permits the following setup:

Application (curl, web browser, etc) ->(plain HTTP)-> local haproxy ->(QSC-SSL)-> haproxy ->(plain HTTP)-> lighttpd

In words: A second HAproxy is configured as a local, application-level VPN tunnel endpoint that any HTTP client application can connect to. It connects in turn to the first HAproxy that is configured on the frontend to provide a QSC-enabled TLS entry port and performs plain HTTP load balancing towards lighttpd as backend.

### Building

Creating the appliance is a two-step process executed by the script `dockerbuild.sh`:

- Compile-Install: All components introduced above are build and installed to a local folder (`opt`)
- Build: Only the resultant libraries and executables are loaded into a minimal Alpine image

## Putting it all together

Pulling all the steps above together, the script `alpine/network-run.sh` configures all components to establish the components in the architecture depicted above: 

- QSC-CA and server keys and certificates are generated
- Set up a docker network into which the following two images are deployed:
- QSC-enabled HAproxy acting as a QSC-TLS enabled load balancer 
- QSC-enabled minimal HAproxy acting as a local plain HTTP communications endpoint and communicating via QSC-secured TLS with the above HAproxy instance 


