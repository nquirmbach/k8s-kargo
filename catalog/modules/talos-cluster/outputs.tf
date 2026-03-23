output "controlplane_ip" {
  description = "Control plane private IP"
  value       = hcloud_server.controlplane.ipv4_address
}

output "worker_ip" {
  description = "Worker private IP"
  value       = hcloud_server.worker.ipv4_address
}

output "controlplane_id" {
  description = "Control plane server ID"
  value       = hcloud_server.controlplane.id
}

output "worker_id" {
  description = "Worker server ID"
  value       = hcloud_server.worker.id
}

output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = "https://${var.api_floating_ip}:6443"
}
