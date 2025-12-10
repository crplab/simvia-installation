## Introduction

Simvia is an SPDM system that allows to manage data and simulations, run computational tasks and process the results. This enterprise level system available for teams up to 5 users for free.

- User guide: https://simvia.ru/release_docs/latest/userguide.pdf
- Installation guide: https://github.com/crplab/simvia-installation
- Docker images: https://hub.docker.com/u/mycesys

## Installation

### Table of content

1. [Requirements](#1-requrements)
2. [Installation](#2-installation-with-simvia-installer)
2.1 [Update with Simvia Installer](#2-1-update-with-simvia-installer) 
2.2. [Manual installation (All in one)](#2-1-manual-installation-all-in-one)
 - [Configuration](#configuration)
 - [Run Simvia & Hub](#run-simvia--hub)
 - [First steps](#first-steps)
3. [Advanced guide](#3-advanced-guide)
-  [Generate and use self-signed SSL certificate](#generate-and-use-self-signed-ssl-certificate)
-  [Install Simvia on several nodes](#install-simvia-on-several-nodes)
4. [Technical details](#4-technical-details)
- [Directories](#list-of-directories)
- [Environment configuration](#environment-configuration)
5. [Troubleshooting](#5-troubleshooting)
6. [Update existing installation](#6-update-existing-installation)
- [2023.1 to 2023.2](#20231-to-20232)
- [2023.2 to 2023.3](#20232-to-20233)
- [2023.4 to 2024.1](#20233-to-20241)
- [2024.1 to 2025.1](#20241-to-20251)
- [2025.1 to 2025.2](#20251-to-20252)
- [2025.2 to 2025.3](#20252-to-20253)

### 1. Requrements

This is a recommended configuration for basic installation. If you need requirements based on your environment and team size please contact us by: [simvia@crplab.ru](mailto:simvia@crplab.ru).

#### Hardware

- Minimal

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| All in one + Hub | 8 | 24 | 512 Gb |

- Optimal

| Node        | CPU | RAM | Disk    |
|-------------|-----|-----|---------|
| All in one  | 12  | 64  | 512 Gb  |
| Hub         | 4   | 16  | 60 Gb   |

- Enterprise

| Node             | CPU | RAM | Disk   |
|------------------| ------ | ------- |--------|
| Hub              | 4 | 16 | 60 Gb  |
| Core             | 8 | 24 | 60 Gb  |
| Task manager     | 8 | 16 | 60 Gb  |
| Resource manager | 8 | 16 | 60 Gb  |
| Workflow         | 4 | 16 | 60 Gb  |
| BFF              | 4 | 16 | 60 Gb  |
| Dashboard        | 4 | 16 | 60 Gb  |
| Files            | 4 | 24 | 512 Gb |
| Gateway          | 4 | 16 | 60 Gb  |
| 3D service       | 4 | 16 | 128 Gb |

#### Software

- `docker` ([Official installation guide](https://docs.docker.com/engine/install/))
- `docker compose` ([Official installation guide](https://docs.docker.com/compose/install/linux/))
- `openssl` (Use your distributive repositories or [official website](https://www.openssl.org/) to install)

#### Host & Network

- Internet access to [Docker Hub](https://hub.docker.com)
- Privileges to run docker containers
- SSL certificate (HTTPS required to support OAuth and native hashing algorithm)
        - If you don't have one you can get it for free from https://letsencrypt.org/ or use self-signed

#### Operating system
- Any operating system that supports docker containers
- We recommend to use one of this operating systems:
  - RedOS
  - AstraLinux
- Installation scripts are now available only for Unix-like operating systems

### 2. Installation with Simvia Installer
 You can use step-by-steb web-based installer to install Simvia

Requirements: 
- `docker` ([Official installation guide](https://docs.docker.com/engine/install/))
- `docker compose` ([Official installation guide](https://docs.docker.com/compose/install/linux/))

How to run:

If you need a new installation of Simvia you must run

```
HYPHA_INSTALL=/opt/simvia; docker run --name simvia-installer -p 3333:3333 -e HYPHA_INSTALL=$HYPHA_INSTALL -v $HYPHA_INSTALL:$HYPHA_INSTALL -v /var/run/docker.sock:/var/run/docker.sock -it mycesys/simvia-installer:2025.3

```

Where `/opt/simvia` is the path to installation.  
And open  http://localhost:3333 address

To stop Simvia installer run

```
docker kill simvia-installer
docker rm simvia-installer
```


2.1 Update with Simvia Installer
You can use simvia-installer to update your existing Simvia installation started from version 2025.2
Just set up your current Simvia installation path as `HYPHA_INSTALL` variable. For example

```
HYPHA_INSTALL=~/simvia; docker run --name hypha-installer -p 3333:3333 -e HYPHA_INSTALL=$HYPHA_INSTALL -v $HYPHA_INSTALL:$HYPHA_INSTALL -v /var/run/docker.sock:/var/run/docker.sock -it mycesys/hypha-installer:2025.3

```

### 2.2. Manual installation (All in one)


**NOTE:** if you already have an installed version of Simvia please check the [Update section](#6-update-existing-installation) of this guide.

#### Configuration

- Docker images at Docker Hub: https://hub.docker.com/u/mycesys
- Sample configuration & scripts: https://github.com/crplab/simvia-installation
  - To download current repository content use this command (or clone it with `git`):

```bash
wget https://github.com/crplab/simvia-installation/archive/refs/heads/main.zip
```

**NEXT STEPS SHOULD BE EXECUTED IN `./allinone` directory**

##### Prepare directories

- Run the following script to create directories:

```bash
./prepare-dirs.sh
```

- Full list of directories could be found in [Technical details / List of directories](#list-of-directories) section.
- **NOTE:** The `files/data` directory is used to store all models and simulation data. Ensure there is enough space available for this purpose.


##### Configure certificates and keys

- OAuth
  - Place the `oauth` (private) and `oauth.pub` (corresponding public) keys in `oauth/keys`. The keys must be generated using the RSA algorithm in PKCS8 format
  - To generate new keys run the script:

```bash
./generate-oauth-keys.sh
```

- SSL
  - Place SSL certificate files into `./ssl` directory

  | File | Description |
  | ------ | ----------------- |
  | `ssl-dhparams.pem` | Diffie-Hellman group |
  | `fullchain.pem` |SSL certificate |
  | `privkey.pem` | SSL private key |
  | `options-ssl-nginx.conf` | SSL configuration file (decribed below) |

  - `options-ssl-nginx.conf` could be found in `selfsigned/` (if you don't have one from SSL certificate provider)
  - To generate self-signed SSL certificate follow the instructions at chapter [3. Advanced guide: generate SSL certificate](#generate-and-use-self-signed-ssl-certificate)

##### Configure `.env` file

- Copy sample environment file to `.env`:

```bash
cp ./dot.env.example ./.env
```

- Required changes in `.env`
  - Redirect URLs

  | Key=Value                                | Description |
  |------------------------------------------| ----------------- |
  | `HUB_PUBLIC_URL=simvia.yourdomain.com`   | place here public address (IP or domain name) of hub instance |
  | `HUB_PUBLIC_PORT=8301`                   | port for Hub interface |
  | `HYPHA_PUBLIC_URL=simvia.yourdomain.com` | place here public address (IP or domain name) of Simvia instance |
  | `HYPHA_PUBLIC_PORT=8300`                 | port for Simvia interface |

  - **NOTE: If you are going to use standard HTTP ports (80 for HTTP and 443 for HTTPS), please set the URLs manually without specifying the port (e.g., ':80' or ':443'), as browsers automatically omit the port in such cases. Parameters described above should be set in any case, sorry for the inconvenience**
  - You should set proper version number for each service. You can check latest versions from [docker hub](https://hub.docker.com/u/mycesys)
  - All other changes in `.env` are optional for all-in-one setup. To learn more follow the guide at: [Technical details / Environment configuration](#environment-configuration)

**For all-in-one installation <HYPHA_PUBLIC_URL> and <HUB_PUBLIC_URL> could be the same but ports should be different.**

#### Run Simvia & Hub

- To start the system run following scripts:

```bash
docker compose pull
```

```bash
docker compose up -d
```

- If you are using a self-signed certificate, do not forget to perform the additional steps described in [3. Advanced guide: addtional configuration steps](#additional-steps)

#### First steps

- Open your browser and follow the link: https://HYPHA_PUBLIC_URL:HYPHA_PUBLIC_PORT
- If you are using a self-signed certificate, you should confirm security exception in browser
- Your should see login form now:
  - Use `admin@mycesys.com` as a login
  - Use `root` as password (if you did not change it in `.env` during the installation process)
- After successful login you will be redirected to Dashboard page
- To learn how to create models, run workflows and more, please take a look at the [user guide](https://simvia.ru/release_docs/latest/userguide.pdf). If you encounter any errors, check our [Troubleshooting](#5-troubleshooting) section.
- Extent your license (to obtain a license file please contact us using our website www.simvia.ru)

### 3. Advanced guide

#### Generate and use self-signed SSL certificate

You can obtain SSL certificate for your DNS record or IP address and use it to secure network connections for free without CA (certificate authority).

**Advantages**
- Free long term SSL certificate
- Easy to manage (creation, changing, prolongation)
- No dependencies on CA

**Disadvantages**
- Browser will ask for confirmation
- Additional steps during installation process

##### How to obtain the certificate

- All actions should be performed in `allinone` directory
- Copy `selfsigned/v3.ext` and `selfsigned/ssl.cnf` to `ssl/`

```bash
cp selfsigned/ssl.cfg ssl/
```

```bash
cp selfsigned/v3.ext ssl/
```

- Fill `ssl/ssl.cfg` with your server parameters
        - `C = RU` - country code
        - `ST = St.Petersburg` - state
        - `L = St.Petersburg` - your city
        - `O = CRPLab` - your organization
        - `OU = Engineering` - your organization unit
        - `CN = example.com` - Common Name: set your server FQDN or IP address here
- Fill `ssl/v3.ext` with your server parameters
  - `subjectAltName = IP:value,DNS:value` - place comma separated pairs `IP:<ip address>` or `DNS:<DNS name>` corresponding to your server
- Run the following script to generate keys (might take some time):

```bash
./generate-ssl-keys.sh
```
- Now you have self signed certificate for 10 years with SAN block. [Return to configuration](#configure-env-file)

##### Additional steps

**Generated SSL certificate must be added to `hub-auth` and `hypha-gateway` JKS keystores**

- Run the following script:
```bash
./add-ssl-keys-to-jdk.sh
```
- **NOTE:** If you did not use the `generate-ssl-keys.sh` script to create SSL certificates, be sure to set the correct passphrase for the private key in the `PASSPHRASE` variable within the `add-ssl-keys-to-jdk.sh` script.


#### Install Simvia on several nodes

- You can spread system components on nodes
- To do it you can use docker compose configuration files from `simvia-installation/` directory to install each component separately
- In this case ensure that you properly set consul URL
- We recommend to start with separating `Hub` components

### 4. Technical details

#### List of directories

| Path                   | Description                                                                                                            |
|------------------------|------------------------------------------------------------------------------------------------------------------------|
| `auth/user/avatars/`   | place where avatars for all users are stored                                                                           |
| `core/common/avatars/` | place where avatars for all other objects are stored                                                                   |
| `files/data/`          | place where all main data is stored (models, simulation results etc). Usually these files take a large amount of space |
| `oauth/keys/`          | place for RSA keys used in OAuth2 authentication process                                                               |
| `ssl/`                 | place for SSL certificates for HTTPS support                                                                           |
| `pg_auth`              | PostgreSQL data directory for authentication service (Hub)                                                             |
| `pg_3d_service`        | PostgreSQL data directory for 3d models service                                                                        |
| `pg_core`              | PostgreSQL data directory for core service                                                                             |
| `pg_dashboard`         | PostgreSQL data directory for dashboard service                                                                        |
| `pg_fm`                | PostgreSQL data directory for files management service                                                                 |
| `pg_rm`                | PostgreSQL data directory for resources management service                                                             |
| `pg_tm`                | PostgreSQL data directory for tasks management service                                                                 |
| `pg_workflow`          | PostgreSQL data directory for workflow management service                                                              |
| `rabbitmq`             | RabbitMQ directory for persistent data                                                                                 |
| `consul_data`          | HashiCorp Consul directory for persistent data                                                                         |
| `vault_data`           | HashiCorp Vault directory for persistent data                                                                          |
| `vault_config`         | HashiCorp Vault directory for configuration                                                                            |

#### Environment configuration

- Secrets

| Key=Value                                                   | Description |
| ----------------------------------------------------------------| ----------------- |
| `HUB_ADMIN_PASSWORD`=root                                   | default password for first user: `admin@simvia.ru` |
| `HUB_AUTH_SECRET`=random_long_string_here                   | strong password (randomly generated) with length no less than 32 characters |
| `HYPHA_SECRET`= random_long_string_here                     | strong password (randomly generated) with length no less than 32 characters |
| `MYC_SERVICE_VAULT_ROLE_ID`= random_long_string_here        | strong password (randomly generated) with length no less than 32 characters |
| `MYC_SERVICE_VAULT_SECRET_ID`= random_long_string_here      | strong password (randomly generated) with length no less than 32 characters |
| `HYPHA_COMMON_CIPHER_KEY`= random_long_string_here          | Used for AES encryption. Should be 32, 24 or 16 symbols lengths |
| `HUB_AUTH_NOTIFICATION_CIPHER_KEY`= random_long_string_here | Used for AES encryption. Should be 32, 24 or 16 symbols length |

- Email Notifications

  | Key=Value                                    | Description                                        |
  |----------------------------------------------|----------------------------------------------------|
  | `HUB_AUTH_MAIL_SERVER_HOST`=smtp.gmail.com   | mail server host                                   |
  | `HUB_AUTH_MAIL_SERVER_POST`=587              | mail server port                                   |
  | `HUB_AUTH_MAIL_USERNAME`=no-reply@simvia.ru| user name (email address) of the mail account      |
  | `HUB_AUTH_MAIL_PASSWORD`=secret              | user password (or token) of the mail account       |
  | `HUB_AUTH_MAIL_PROTOCOL`=smtp                | protocol used for emails transferring              |
  | `HUB_AUTH_MAIL_SMTP_AUTH`=true               | use mail account authentication                    |
  | `HUB_AUTH_MAIL_TLS_ENABLE`=true              | use STARTLS protocol                               |
  | `HUB_AUTH_MAIL_SSL_ENABLE`=false             | use SSL protocol                                   |
  | `HUB_AUTH_MAIL_FROM`=no-reply@simvia.ru    | email address from which notifications will be sent |


### 5. Troubleshooting

#### Common techniques

- To check all running containers run:

```bash
docker ps
```

- To look at specific container system.output (logs) run:

```bash
docker logs <container_name> | less
```

- To look at nat routing rules in iptables run:

```bash
iptables -t nat -L --line-numbers
```

#### Issues with environment configuration

- Symptom: Endless redirects and reloading when trying to access the login page
  - Check `HYPHA_PUBLIC_URL` and `HUB_PUBLIC_URL` in `.env` file: they should refer to either `localhost` or `127.0.0.1` because each docker container has its own `localhost`
  - Check SSL certificate parameters (described below)

#### Issues with self-signed SSL certificate

- Symptom: some requests ends with 500 status code and  `java.security.cert.CertificateException` appears in the logs
  - Java stacktrace

```java
Caused by: java.security.cert.CertificateException: No subject alternative names present
 at java.base/sun.security.util.HostnameChecker.matchIP(Unknown Source)
 at java.base/sun.security.util.HostnameChecker.match(Unknown Source)
 at java.base/sun.security.ssl.X509TrustManagerImpl.checkIdentity(Unknown Source)
 at java.base/sun.security.ssl.X509TrustManagerImpl.checkIdentity(Unknown Source)
 at java.base/sun.security.ssl.X509TrustManagerImpl.checkTrusted(Unknown Source)
 at java.base/sun.security.ssl.X509TrustManagerImpl.checkServerTrusted(Unknown Source)
```

  - Check your SSL certificate in browser (guide for Chrome browser)
    - click certificate icon in URL field in browser and then click `certificate details`
    - switch to `details` tab
    - Find `Certificate -> Extension -> Certificate Subject Alternative Name`
    - This section should exits
    - DNS names or IPs should refer to your server DNS/IP
- Symptom: HTTP requests with `500` status code, exceptions in logs like:

```
org.springframework.security.oauth2.jwt.JwtDecoderInitializationException: Failed to lazily resolve the supplied JwtDecoder instance
```
  - Ensure that you have added SSL certificates to JDK ([3. Advanced guide: addtional configuration steps](#additional-steps))

#### Issues with routing

- Symptom: `Connection refused` error in logs after login attemp.
  - Environment: often reproduces when system is installed on VM with ports forwading (maybe on router)
  - Check: try to call an API method `https:<HUB_URL>/oauth2/jwks`, it should be accessible from host and from `hub-auth`, `hypha-gateway` docker containers
```bash
curl -k --location --request GET https://<HUB_URL>/oauth2/jwks
```
  - If it fails than you need some routing configuration to make it working fine
  - Here is an example:

![Environment scheme]()

  - On this scheme all `Connections` should work properly
  - To allow connections from VM to `Public interface` you should add following rules (iptables):

```bash
iptables -t nat -A POSTROUTING --source yyy.yyy.yyy.yyy  --destination xxx.xxx.xxx.xxx -p tcp --dport 6080 -j SNAT --to-source yyy.yyy.yyy.yyy
iptables -t nat -A POSTROUTING --source yyy.yyy.yyy.yyy  --destination xxx.xxx.xxx.xxx -p tcp --dport 6081 -j SNAT --to-source yyy.yyy.yyy.yyy
```
  - To allow connections from docker containers to `Public interface` you can add following line to `hypha-gateway` and `hub-auth` sections in docker-compose.yml:

```yml
 extra_hosts:
      - "<HYPHA_PUBLIC_DOMAIN>:yyy.yyy.yyy.yyy"
```

### 6. Update existing installation

**Before update:**

- We are strongly recommending to back up:
  - all databases
  - data from 'files/data' directory
  - configuration
- If you made any changes to `docker-compose.yml` in previous installation please ensure that you create a backup.

#### 2023.1 to 2023.2

**Update version**

1. Download `config-migration_2023.1-2-2023.2.sh` script from the [repository](https://github.com/crplab/simvia-installation/tree/2023.2/allinone/)
2. Run migration script
- Run script `config-migration_2023.1-2-2023.2.sh` in `./allinone` directory

```bash
./config-migration_2023.1-2-2023.2.sh
```

- For more details please run:

```bash
./config-migration_2023.1-2-2023.2.sh --help
```

- Please check new `.env` file generated by script before start
- Please check new `docker-compose.yml` file before start. If you made any changes during the installation of previous version, please sync them with new version of this file.
- Please check new nginx configuration files:
  - `nginx.hub_frontend.conf`
  - `nginx.hypha_frontend.conf`
3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d
```

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2023.2 to 2023.3

**Update version**

1. Download `config-migration_2023.2-2-2023.23.sh` script from the [repository](https://github.com/crplab/simvia-installation/tree/2023.3/allinone/)
2. Run migration script
- Run script `config-migration_2023.2-2-2023.3.sh` in `./allinone` directory

```bash
./config-migration_2023.2-2-2023.3.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables `DISCOVERY_PREFER_IP` and `DISCOVERY_IP_ADDRESS` are presented 
- Please check new `docker-compose.yml` file before start. If you made any changes during the installation of previous version, please sync them with new version of this file.
- Please use new `ssl_cert.conf` file for SSL/TLS certificates setup.

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2023.3 to 2024.1

**Update version**

1. Download `config-migration_2023.3-2-2024.1.sh` script from the [repository](https://github.com/crplab/simvia-installation/tree/2024.1/allinone/)
2. Run migration script
- Run script `config-migration_2023.2-2-2023.3.sh` in `./allinone` directory

```bash
./config-migration_2023.3-2-2024.1.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables `DISCOVERY_PREFER_IP` and `DISCOVERY_IP_ADDRESS` are presented 
- Now `docker-compose.yml` is splitted by services. Please check new `docker-compose.yml` file before start. If you made any changes during the installation of previous version, please sync them with new version of this file.
- Please use new `ssl_cert.conf` file for SSL/TLS certificates setup.

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2024.1 to 2025.1

**Update version**

1. Download `config-migration_2024.1-2025.1.sh` script from the [repository](https://github.com/crplab/simvia-installation/tree/2025.1/allinone/)
2. Run migration script
- Run script `config-migration_2024.1-2025.1.sh` in `./allinone` directory

```bash
./config-migration_2024.1-2025.1.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables about 3d-service are presented 

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```

#### 2025.1 to 2025.2

**Update version**

1. Download `config-migration_2025.1-2025.2.sh` script from the [repository](https://github.com/crplab/simvia-installation/tree/2025.2/allinone/)
2. Run migration script
- Run script `config-migration_2025.1-2025.2.sh` in `./allinone` directory

```bash
./config-migration_2025.1-2025.2.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables about branding and i18n are presented 

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```
#### 2025.2 to 2025.3

**Update version**

1. Download `config-migration_2025.2-2025.3.sh` script from the [repository](https://github.com/crplab/simvia-installation/tree/2025.3/allinone/config-migration_2025.2-2025.3.sh)
2. Run migration script
- Run script `config-migration_2025.2-2025.3.sh` in `./allinone` directory

```bash
./config-migration_2025.2-2025.3.sh
```
- Please check new `.env` file generated by script before start. Set new versions for services, you can get them from https://hub.docker.com/u/mycesys. Check if new variables about branding and i18n are presented 

3. To update images and restart system run:

```bash
docker compose pull
```

```bash
docker compose up -d --remove-orphans
```

If you are using selfsigned certificates:

```bash
./add-ssl-keys-to-jdk.sh
```
