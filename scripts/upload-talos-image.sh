#!/bin/bash
set -e

TALOS_VERSION="${1:-v1.12.6}"
ARCH="amd64"

echo "Downloading TalOS ${TALOS_VERSION} image..."
wget -O /tmp/talos-${TALOS_VERSION}-${ARCH}.raw.xz \
  "https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/${TALOS_VERSION}/hcloud-${ARCH}.raw.xz"

echo "Installing hcloud-upload-image..."
if ! command -v hcloud-upload-image &> /dev/null; then
    go install github.com/apricote/hcloud-upload-image@latest
fi

echo "Uploading image to Hetzner Cloud..."
hcloud-upload-image upload \
    --image-path /tmp/talos-${TALOS_VERSION}-${ARCH}.raw.xz \
    --architecture x86 \
    --compression xz \
    --description "TalOS ${TALOS_VERSION} ${ARCH}" \
    --label os=talos \
    --label version=${TALOS_VERSION} \
    --label arch=${ARCH}

echo "Cleaning up..."
rm /tmp/talos-${TALOS_VERSION}-${ARCH}.raw.xz

echo "Done! Image uploaded successfully."
echo "You can now use 'talos-${TALOS_VERSION}-${ARCH}' as image name in Terraform."
