#!/bin/bash
set -e

echo "Building TalOS images for Hetzner Cloud..."

# Check if Packer is installed
if ! command -v packer &> /dev/null; then
    echo "Packer is not installed. Please install Packer first."
    echo "Visit: https://www.packer.io/downloads"
    exit 1
fi

# Check if HCLOUD_TOKEN is set
if [ -z "$HCLOUD_TOKEN" ]; then
    echo "HCLOUD_TOKEN environment variable is not set."
    echo "Please set it with: export HCLOUD_TOKEN=\"your-hcloud-api-token\""
    exit 1
fi

echo "Initializing Packer..."
packer init .

echo "Building TalOS image..."
packer build .

echo "TalOS image build complete!"
echo "Verify with: hcloud image list --selector os=talos"
