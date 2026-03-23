include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/catalog/modules//talos-cluster"
}

dependency "networking" {
  config_path = "../networking"
  
  mock_outputs = {
    network_id      = 12345678
    subnet_id       = "12345678-10.1.1.0/24"
    firewall_id     = 12345678
    api_floating_ip = "10.0.0.1"
    api_floating_ip_id = 12345678
  }
}

inputs = {
  environment             = "stage"
  location                = "hel1"
  cluster_name            = "kargo-stage"
  kubernetes_version      = "v1.32.13"
  talos_version           = "v1.12.6"
  control_plane_node_type = "cx23"
  worker_node_type        = "cx23"
  network_id              = dependency.networking.outputs.network_id
  subnet_id               = dependency.networking.outputs.subnet_id
  firewall_id             = dependency.networking.outputs.firewall_id
  api_floating_ip_id      = dependency.networking.outputs.api_floating_ip_id
  api_floating_ip         = dependency.networking.outputs.api_floating_ip
}
