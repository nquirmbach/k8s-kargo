# Generate Talos secrets
resource "talos_machine_secrets" "this" {}

# Talos machine configuration data
data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.api_floating_ip}:6443"
  machine_type       = "controlplane"
  kubernetes_version = var.kubernetes_version
  machine_secrets    = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "${var.cluster_name}-controlplane"
          interfaces = [{
            deviceSelector = {
              hardwareAddr = "96:00:00:00:00:02"
            }
            dhcp = true
          }]
        }
        install = {
          image = "ghcr.io/siderolabs/installer:${var.talos_version}"
          disk  = "/dev/sda"
        }
      }
      cluster = {
        network = {
          podSubnets     = ["10.244.0.0/16"]
          serviceSubnets = ["10.96.0.0/12"]
        }
      }
    })
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.api_floating_ip}:6443"
  machine_type       = "worker"
  kubernetes_version = var.kubernetes_version
  machine_secrets    = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "${var.cluster_name}-worker"
          interfaces = [{
            deviceSelector = {
              hardwareAddr = "96:00:00:00:00:03"
            }
            dhcp = true
          }]
        }
        install = {
          image = "ghcr.io/siderolabs/installer:${var.talos_version}"
          disk  = "/dev/sda"
        }
      }
    })
  ]
}

# Control Plane Server
resource "hcloud_server" "controlplane" {
  name        = "${var.cluster_name}-controlplane"
  server_type = var.control_plane_node_type
  image       = "ubuntu-22.04"
  location    = var.location

  network {
    network_id = var.network_id
    ip         = "10.1.1.100"
  }

  firewall_ids = [var.firewall_id]

  user_data = data.talos_machine_configuration.controlplane.machine_configuration

  labels = {
    environment = var.environment
    cluster     = var.cluster_name
    role        = "controlplane"
  }
}

# Worker Server
resource "hcloud_server" "worker" {
  name        = "${var.cluster_name}-worker"
  server_type = var.worker_node_type
  image       = "ubuntu-22.04"
  location    = var.location

  network {
    network_id = var.network_id
    ip         = "10.1.1.101"
  }

  firewall_ids = [var.firewall_id]

  user_data = data.talos_machine_configuration.worker.machine_configuration

  labels = {
    environment = var.environment
    cluster     = var.cluster_name
    role        = "worker"
  }
}

# Assign floating IP to control plane
resource "hcloud_floating_ip_assignment" "api" {
  floating_ip_id = var.api_floating_ip_id
  server_id      = hcloud_server.controlplane.id
}

# Apply Talos machine configurations
resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = hcloud_server.controlplane.ipv4_address
  endpoint                    = hcloud_server.controlplane.ipv4_address
}

resource "talos_machine_configuration_apply" "worker" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = hcloud_server.worker.ipv4_address
  endpoint                    = hcloud_server.controlplane.ipv4_address
}
