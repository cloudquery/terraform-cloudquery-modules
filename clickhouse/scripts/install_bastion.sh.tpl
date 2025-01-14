#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# Configure environment
export DEBIAN_FRONTEND=noninteractive

# Function to handle errors
handle_error() {
    echo "Error occurred on line $$1"
    exit 1
}
trap 'handle_error $$LINENO' ERR

echo "Starting system setup..."

# Update package lists
apt-get update

# Install AWS CLI
echo "Installing AWS CLI..."
apt-get install -y unzip
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Setup ClickHouse Repository
echo "Setting up ClickHouse repository..."
apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | \
    gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg

# Add ClickHouse repository
ARCH=$(dpkg --print-architecture)
echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=$${ARCH}] \
    https://packages.clickhouse.com/deb stable main" | \
    tee /etc/apt/sources.list.d/clickhouse.list
apt-get update

# Install ClickHouse
echo "Installing ClickHouse..."
apt-get install -y clickhouse-server clickhouse-client

echo "Setup completed successfully!"
