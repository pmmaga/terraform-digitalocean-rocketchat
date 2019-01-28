# terraform-digitalocean-rocketchat
A terraform module to spawn a digital ocean droplet running Rocket.Chat

## What do you need?
- A DigitalOcean API Personal access token
- The fingerprint of at least one ssh key which you setup on DigitalOcean
- Setup your desired domain to use DigitalOcean's NameServers [more info](https://www.digitalocean.com/community/tutorials/how-to-point-to-digitalocean-nameservers-from-common-domain-registrars)

## What do you get?
- The domain will be managed in DO, with an A record already pointing to your droplet
- A firewall setup also managed in DO, already attached to your droplet
- The droplet itself
    - Running Rocket.Chat as a snap
    - With nginx acting as a frontend
    - With certbot configured for your chosen domain and redirecting http to https
