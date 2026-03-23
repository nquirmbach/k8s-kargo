include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/catalog/modules//talos-cluster"
}

inputs = {
  environment             = "stage"
  location                = "hel1"
  cluster_name            = "kargo-stage"
  kubernetes_version      = "v1.32.13"
  talos_version           = "v1.12.6"
  control_plane_node_type = "cx23"
  worker_node_type        = "cx23"
  network_id              = 12055619
  subnet_id               = "12055619-10.1.1.0/24"
  firewall_id             = 10736178
  api_floating_ip_id      = 123181114
  api_floating_ip         = "65.109.243.73"
}
