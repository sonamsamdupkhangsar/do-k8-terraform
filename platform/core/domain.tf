resource "digitalocean_domain" "my_domain" {
  count = var.create_domain ? 1 : 0

  name = var.domain_name
}
