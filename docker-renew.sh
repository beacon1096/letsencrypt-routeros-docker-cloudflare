docker run -it --rm --name certbot \
-v "/opt/certbot/etc:/etc/letsencrypt" \
-v "/opt/certbot/lib:/var/lib/letsencrypt" \
-v "/opt/certbot/scripts:/scripts" \
-v "/opt/certbot/ssh:/root/.ssh" \
beacon1096/certbot-cloudflare-bash-openssh:arm64v8-20210817 renew --dry-run