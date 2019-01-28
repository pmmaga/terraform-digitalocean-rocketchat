resource "digitalocean_droplet" "rocket-chat" {
  image  = "debian-9-x64"
  name   = "rocket-chat"
  region = "${var.droplet_region}"
  size   = "${var.droplet_size}"

  ssh_keys = "${var.ssh_key_fingerprints}"

  connection {
    user        = "root"
    type        = "ssh"
    private_key = "${file(var.priv_key)}"
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y install snapd nginx",
      "sudo snap install rocketchat-server",
    ]
  }

  provisioner "file" {
    destination = "/etc/nginx/sites-enabled/default"

    content = <<EOF
upstream backend {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name ${var.domain_name};

    location / {
        proxy_pass http://backend/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forward-Proto http;
        proxy_set_header X-Nginx-Proxy true;

        proxy_redirect off;
    }
}
EOF
  }
}

resource "null_resource" "configure-certbot" {
  # Using a null_resource to defer part of the droplet configuration to after the domain is setup
  depends_on = ["digitalocean_domain.rocket-chat-domain"]

  connection {
    user        = "root"
    type        = "ssh"
    private_key = "${file(var.priv_key)}"
    timeout     = "2m"
    host        = "${digitalocean_droplet.rocket-chat.ipv4_address}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /opt/certbot",
      "cd /opt/certbot",
      "wget https://dl.eff.org/certbot-auto",
      "chmod a+x ./certbot-auto",
      "./certbot-auto --non-interactive --agree-tos --email ${var.letsencrypt_mail} --nginx --redirect --domains ${var.domain_name}",
    ]
  }

  provisioner "file" {
    destination = "/etc/cron.d/certbot"

    content = <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 */12 * * * root test -x /opt/certbot/certbot-auto -a \! -d /run/systemd/system && perl -e 'sleep int(rand(3600))' && /opt/certbot/certbot-auto -q renew
EOF
  }
}
