packer {
  required_plugins {
    hcloud = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hcloud"
    }
  }
}

variable "hcloud_token" {
  type    = string
  default = env("HCLOUD_TOKEN")
}

variable "talos_version" {
  type    = string
  default = "v1.12.6"
}

variable "image_url_x86" {
  type    = string
  default = "https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.12.6/hcloud-amd64.raw.xz"
}

source "hcloud" "talos-amd64" {
  token          = var.hcloud_token
  image          = "ubuntu-22.04"
  server_type    = "cx23"
  location       = "hel1"
  ssh_username   = "root"
  snapshot_name  = "talos-${var.talos_version}-amd64"
  snapshot_labels = {
    os      = "talos"
    version = var.talos_version
    arch    = "amd64"
  }
}

build {
  name = "talos-amd64"
  sources = [
    "source.hcloud.talos-amd64"
  ]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get install -y wget xz-utils",
      "cd /tmp",
      "wget \"${var.image_url_x86}\" -O talos.raw.xz",
      "unxz talos.raw.xz",
      "dd if=talos.raw of=/dev/sda bs=1M status=progress"
    ]
  }
}
