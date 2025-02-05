#!/bin/bash

# Exit on error, undefined vars, and pipe failures
set -euo pipefail

# Script configuration
export DEBIAN_FRONTEND=noninteractive
CLOUDWATCH_CONFIG_PATH="/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"
CLICKHOUSE_CONFIG_DIR="/etc/clickhouse-server/config.d"
KEEPER_CONFIG_PATH="/etc/clickhouse-keeper/keeper_config.xml"

# Function definitions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

handle_error() {
    log "Error occurred on line $1"
    exit 1
}

setup_ssm() {
    log "Setting up SSM Agent..."
    # Check if SSM agent is installed
    if [ ! -f /snap/amazon-ssm-agent/current/amazon-ssm-agent ]; then
        log "Installing SSM Agent..."
        snap install amazon-ssm-agent --classic
    fi

    # Ensure SSM agent is running
    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
    systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

    log "SSM Agent status:"
    systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service || true
}

install_aws_cli() {
    log "Installing AWS CLI..."
    apt-get install -y unzip
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
}

setup_clickhouse_repo() {
    log "Setting up ClickHouse repository..."
    apt-get install -y apt-transport-https ca-certificates curl gnupg

    # Import GPG key
    curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | \
        gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg

    # Add repository
    ARCH=$(dpkg --print-architecture)
    echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=$${ARCH}] \
        https://packages.clickhouse.com/deb stable main" | \
        tee /etc/apt/sources.list.d/clickhouse.list

    apt-get update
}

install_cloudwatch_agent() {
    log "Installing CloudWatch Agent..."
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb
    dpkg -i -E ./amazon-cloudwatch-agent.deb
    rm -f ./amazon-cloudwatch-agent.deb
}

setup_ebs_volume() {
    log "Setting up EBS volume..."

    # Wait for device to be available
    sleep 10

    # Find the actual device name - could be xvdh or nvme
    DEVICE_NAME=""
    if [ -e "/dev/xvdh" ]; then
        DEVICE_NAME="/dev/xvdh"
        log "Found traditional device naming: ${DEVICE_NAME}"
    elif [ -e "/dev/nvme1n1" ]; then
        DEVICE_NAME="/dev/nvme1n1"
        log "Found NVMe device naming: ${DEVICE_NAME}"
    else
        # List available devices for debugging
        log "Available devices:"
        lsblk
        ls -la /dev/nvme* || true
        ls -la /dev/xvd* || true
        log "Error: Could not find EBS volume device"
        exit 1
    fi

    # Format and mount the volume
    log "Formatting ${DEVICE_NAME} with XFS"
    mkfs.xfs ${DEVICE_NAME}

    log "Creating mount point at /var/lib/clickhouse"
    mkdir -p /var/lib/clickhouse

    log "Mounting ${DEVICE_NAME} to /var/lib/clickhouse"
    mount ${DEVICE_NAME} /var/lib/clickhouse

    log "Adding to fstab"
    echo "${DEVICE_NAME}  /var/lib/clickhouse  xfs  defaults  0  0" >> /etc/fstab

    log "Setting permissions"
    chown -R clickhouse:clickhouse /var/lib/clickhouse
}

setup_clickhouse_server() {
    log "Setting up ClickHouse server..."

    # Setup EBS volume
    setup_ebs_volume

    # Install ClickHouse
    apt-get install -y clickhouse-server clickhouse-client

    # Copy configurations
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/cloudwatch.json" "$${CLOUDWATCH_CONFIG_PATH}"
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/config.d/" "$${CLICKHOUSE_CONFIG_DIR}" --recursive

    # Start service
    service clickhouse-server start
}

setup_clickhouse_keeper() {
    log "Setting up ClickHouse Keeper..."

    # Setup EBS volume
    setup_ebs_volume

    # Create additional directories
    mkdir -p /var/lib/clickhouse/coordination/logs
    mkdir -p /var/lib/clickhouse/coordination/snapshots
    chown -R clickhouse:clickhouse /var/lib/clickhouse

    # Install and configure Keeper
    apt-get install -y clickhouse-keeper

    # Copy configurations
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/cloudwatch.json" "$${CLOUDWATCH_CONFIG_PATH}"
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/keeper_config.xml" "$${KEEPER_CONFIG_PATH}"

    # Start service
    systemctl enable clickhouse-keeper
    systemctl start clickhouse-keeperr
}

start_cloudwatch_agent() {
    log "Starting CloudWatch Agent..."
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -c "file://$${CLOUDWATCH_CONFIG_PATH}" \
        -s
}

setup_certificates() {
    if [ "${enable_encryption}" = true ]; then
        # Generate self-signed certificate for node-to-node communication
        openssl req -x509 -newkey rsa:${ssl_key_bits} \
            -nodes -days ${ssl_cert_days} \
            -keyout /etc/clickhouse-server/server.key \
            -out /etc/clickhouse-server/server.crt \
            -subj "/CN=${node_name}.${internal_domain}"

        # Set correct permissions
        chown clickhouse:clickhouse /etc/clickhouse-server/server.key
        chown clickhouse:clickhouse /etc/clickhouse-server/server.crt
        chmod 600 /etc/clickhouse-server/server.key
    fi
}

# Main script execution
trap 'handle_error $LINENO' ERR

log "Starting system setup..."
apt-get update

setup_ssm
install_aws_cli
setup_clickhouse_repo
install_cloudwatch_agent

if [ "${clickhouse_server}" = true ]; then
    setup_clickhouse_server
else
    setup_clickhouse_keeper
fi

setup_certificates
start_cloudwatch_agent
log "Setup completed successfully!"
