# Private Network for the cluster
resource "hcloud_network" "this" {
  name     = "${var.cluster_name}-network"
  ip_range = var.network_cidr
}

# Subnet for the nodes
resource "hcloud_network_subnet" "this" {
  network_id   = hcloud_network.this.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.subnet_cidr
}

# Firewall for the cluster
resource "hcloud_firewall" "this" {
  name = "${var.cluster_name}-firewall"

  # Allow SSH from anywhere (restrict in production)
  rule {
    direction       = "in"
    protocol        = "tcp"
    port            = "22"
    source_ips      = ["0.0.0.0/0"]
    destination_ips = []
  }

  # Allow Kubernetes API server
  rule {
    direction       = "in"
    protocol        = "tcp"
    port            = "6443"
    source_ips      = ["0.0.0.0/0"]
    destination_ips = []
  }

  # Allow Talos API
  rule {
    direction       = "in"
    protocol        = "tcp"
    port            = "50000"
    source_ips      = ["0.0.0.0/0"]
    destination_ips = []
  }

  # Allow intra-cluster traffic
  rule {
    direction       = "in"
    protocol        = "tcp"
    port            = "any"
    source_ips      = [var.subnet_cidr]
    destination_ips = []
  }

  rule {
    direction       = "in"
    protocol        = "udp"
    port            = "any"
    source_ips      = [var.subnet_cidr]
    destination_ips = []
  }

  # Allow ICMP
  rule {
    direction       = "in"
    protocol        = "icmp"
    source_ips      = ["0.0.0.0/0"]
    destination_ips = []
  }
}

# Floating IP for API server access
resource "hcloud_floating_ip" "api" {
  type          = "ipv4"
  home_location = var.location
  name          = "${var.cluster_name}-api"
}

# Floating IP for Ingress (optional)
resource "hcloud_floating_ip" "ingress" {
  type          = "ipv4"
  home_location = var.location
  name          = "${var.cluster_name}-ingress"
}
