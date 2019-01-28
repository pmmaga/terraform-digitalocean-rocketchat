resource "digitalocean_domain" "rocket-chat-domain" {
  name       = "${var.domain_name}"
  ip_address = "${digitalocean_droplet.rocket-chat.ipv4_address}"
}

resource "digitalocean_firewall" "rocket-chat-fw" {
  name = "inbound-ping-22-80-and-443"

  droplet_ids = ["${digitalocean_droplet.rocket-chat.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "icmp"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}
