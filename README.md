So you can deploy certificates to ssh-compatible devices (like Mikrotik RouterOS devices) with openssh in docker!  
```Dockerfile
FROM certbot/dns-cloudflare:arm64v8-latest
RUN apk add --no-cache bash openssh 
```
There's a great chance that I'm not building this image frequently so probably you should just build it locally,   
and I only made a arm64 build as for now.  
Checkout certbot's docs to get some ideas, especially if you want to deploy your certs & keys to other linux devices other than RouterOS by making another post-hook script    
Check the dockerfile if you're looking into switching to another DNS provider plugin  
Checkout https://github.com/gitpel/letsencrypt-routeros about deploying certs & keys to RouterOS devices  

You'll still need to configure cron to renew your certs automatically  


  
# Let's Encrypt RouterOS / Mikrotik
**Let's Encrypt certificates for RouterOS / Mikrotik**

*UPD 2018-05-27: Works with wildcard Let's Encrypt Domains*

[![Mikrotik](https://i.mt.lv/mtv2/logo.svg)](https://mikrotik.com/)


### How it works:
* Dedicated Linux renew and push certificates to RouterOS / Mikrotik
* After CertBot renew your certificates
* The script connects to RouterOS / Mikrotik using DSA Key (without password or user input)
* Delete previous certificate files
* Delete the previous certificate
* Upload two new files: **Certificate** and **Key**
* Import **Certificate** and **Key**
* Change **SSTP Server Settings** to use new certificate
* Delete certificate and key files form RouterOS / Mikrotik storage

### Installation on Any Docker-Enabled System
*Tested on Openwrt 21 Arm64*  

*Similar way you can use on Debian/CentOS/AMI Linux/Arch/Others*

Download the repo to your system
```sh
sudo -s
cd /opt
git clone https://github.com/beacon1096/letsencrypt-routeros-docker-cloudflare
```
Edit the settings file:
```sh
vim /opt/letsencrypt-routeros-docker-cloudflare/scripts/letsencrypt-routeros.settings
```
| Variable Name | Value | Description |
| ------ | ------ | ------ |
| ROUTEROS_USER | admin | user with admin rights to connect to RouterOS |
| ROUTEROS_HOST | 10.0.254.254 | RouterOS\Mikrotik IP |
| ROUTEROS_SSH_PORT | 22 | RouterOS\Mikrotik PORT |
| ROUTEROS_PRIVATE_KEY | /opt/letsencrypt-routeros/id_dsa | Private Key to connecto to RouterOS |
| DOMAIN | mydomain.com | Use main domain for wildcard certificate or subdomain for subdomain certificate |


Change permissions:
```sh
chmod +x /opt/letsencrypt-routeros-docker-cloudflare/scripts/letsencrypt-routeros.sh
```
Generate RSA Key for RouterOS

*Make sure to leave the passphrase blank (-N "")*  

*Or generate it interactively without this parameter*

```sh
ssh-keygen -t rsa -f /opt/letsencrypt-routeros-docker-cloudflare/scripts/id_rsa -N ""
```

Send Generated RSA Key to RouterOS / Mikrotik
```sh
source /opt/letsencrypt-routeros-docker-cloudflare/scripts/letsencrypt-routeros.settings
scp -P $ROUTEROS_SSH_PORT /opt/letsencrypt-routeros-docker-cloudflare/scripts/id_rsa.pub "$ROUTEROS_USER"@"$ROUTEROS_HOST":"id_rsa.pub" 
```

### Setup RouterOS / Mikrotik side
*Check that user is the same as in the settings file letsencrypt-routeros.settings*

*Check Mikrotik ssh port in /ip services ssh*

*Check Mikrotik firewall to accept on SSH port*
```sh
:put "Enable SSH"
/ip service enable ssh

:put "Add to the user RSA Public Key"
/user ssh-keys import user=admin public-key-file=id_rsa.pub
```

### CertBot Let's Encrypt
Open docker-cert.sh and have a check  

Change *\*.{DOMAIN}* to your domain. Wildcard will work as well

Select the correct tag according to your architecture, for arm64 the one I'm using is arm64v8:20210817

run the setup script  

*follow CertBot instructions*

```sh
/opt/letsencrypt-routeros-docker-cloudflare/docker-cert.sh
```
You'll need to manually confirm the *authenticity of host* in your first run.

To renew, checkout https://certbot.eff.org/docs/using.html#automated-renewals and replace 
```sh
certbot renew -q
```
with
```sh
/opt/letsencrypt-routeros-docker-cloudflare/docker-renew.sh
```

### Usage of the RouterOS script
*To use settings form the settings file:*
```sh
./opt/letsencrypt-routeros/letsencrypt-routeros.sh
```
*To use script without settings file:*

```sh
./opt/letsencrypt-routeros/letsencrypt-routeros.sh [RouterOS User] [RouterOS Host] [SSH Port] [SSH Private Key] [Domain]
```
*To use script with CertBot hooks for wildcard domain:*
```sh
certbot certonly --preferred-challenges=dns --manual -d *.$DOMAIN --manual-public-ip-logging-ok --post-hook /opt/letsencrypt-routeros/letsencrypt-routeros.sh --server https://acme-v02.api.letsencrypt.org/directory
```
*To use script with CertBot hooks for subdomain:*
```sh
certbot certonly --preferred-challenges=dns --manual -d $DOMAIN --manual-public-ip-logging-ok --post-hook /opt/letsencrypt-routeros/letsencrypt-routeros.sh
```

### Edit Script
You can easily edit script to execute your commands on RouterOS / Mikrotik after certificates renewal
Add these strings in the «.sh» file before «exit 0» to have www-ssl and api-ssl works with Let's Encrypt SSL
```sh
$routeros /ip service set www-ssl certificate=$DOMAIN.pem_0
$routeros /ip service set api-ssl certificate=$DOMAIN.pem_0
```
---
### Licence MIT
Copyright 2018 Konstantin Gimpel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
