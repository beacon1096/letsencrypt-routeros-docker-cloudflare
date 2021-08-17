docker run -it --rm --name certbot \
-v "/opt/certbot/etc:/etc/letsencrypt" \
-v "/opt/certbot/lib:/var/lib/letsencrypt" \
-v "/opt/certbot/scripts:/scripts" \
-v "/opt/certbot/ssh:/root/.ssh/" \
beacon1096/certbot-cloudflare-bash-openssh certonly --dns-cloudflare \
--dns-cloudflare-credentials /scripts/cloudflare.credentials \
-d *.{DOMAIN} \
--manual-public-ip-logging-ok \
--register-unsafely-without-email \
--post-hook /scripts/letsencrypt-routeros.sh 