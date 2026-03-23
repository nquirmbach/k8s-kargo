variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Hetzner location"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.32.13"
}

variable "talos_version" {
  description = "Talos version"
  type        = string
  default     = "v1.12.6"
}

variable "control_plane_node_type" {
  description = "Server type for control plane nodes"
  type        = string
}

variable "worker_node_type" {
  description = "Server type for worker nodes"
  type        = string
}

variable "network_id" {
  description = "Network ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "firewall_id" {
  description = "Firewall ID"
  type        = string
}

variable "api_floating_ip_id" {
  description = "Floating IP ID for API server"
  type        = number
}

variable "api_floating_ip" {
  description = "API server floating IP"
  type        = string
}
