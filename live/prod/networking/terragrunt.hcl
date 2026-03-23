include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/catalog/modules//networking"
}

inputs = {
  environment  = "prod"
  location     = "nbg1"
  network_cidr = "10.2.0.0/16"
  subnet_cidr  = "10.2.1.0/24"
  cluster_name = "kargo-prod"
}
