output "network_id" {
  description = "ID of the private network"
  value       = hcloud_network.this.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = hcloud_network_subnet.this.id
}

output "firewall_id" {
  description = "ID of the firewall"
  value       = hcloud_firewall.this.id
}

output "api_floating_ip_id" {
  description = "Floating IP ID for API server"
  value       = hcloud_floating_ip.api.id
}

output "api_floating_ip" {
  description = "Floating IP for API server"
  value       = hcloud_floating_ip.api.ip_address
}

output "ingress_floating_ip" {
  description = "Floating IP for Ingress"
  value       = hcloud_floating_ip.ingress.ip_address
}

output "network_cidr" {
  description = "Network CIDR"
  value       = var.network_cidr
}

output "subnet_cidr" {
  description = "Subnet CIDR"
  value       = var.subnet_cidr
}
