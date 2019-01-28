variable do_token {
  type = "string"
}

variable droplet_region {
  type = "string"
}

variable droplet_size {
  type = "string"

  default = "s-1vcpu-1gb"
}

variable domain_name {
  type = "string"
}

variable letsencrypt_mail {
  type = "string"
}

variable ssh_key_fingerprints {
  type = "list"
}

variable ssh_priv_key_path {
  type = "string"
}
