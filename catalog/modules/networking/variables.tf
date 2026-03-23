variable "environment" {
  description = "Environment name (stage/prod)"
  type        = string
}

variable "location" {
  description = "Hetzner location"
  type        = string
  default     = "nbg1"
}

variable "network_cidr" {
  description = "Network CIDR block"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}
