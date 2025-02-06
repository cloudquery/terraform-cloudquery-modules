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
    if [ ! -f /snap/amazon-ssm-agent/current/amazon-ssm-agent ]; then
        log "Installing SSM Agent..."
        snap install amazon-ssm-agent --classic
    fi
    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
    systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
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

    curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | \
        gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg

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
    local mount_path=$1
    log "Setting up EBS volume for $mount_path..."

    # Wait for device to be available
    sleep 10

    # Find the actual device name
    DEVICE_NAME=""
    if [ -e "/dev/xvdh" ]; then
        DEVICE_NAME="/dev/xvdh"
        log "Found traditional device naming: $${DEVICE_NAME}"
    elif [ -e "/dev/nvme1n1" ]; then
        DEVICE_NAME="/dev/nvme1n1"
        log "Found NVMe device naming: $${DEVICE_NAME}"
    else
        log "Available devices:"
        lsblk
        ls -la /dev/nvme* || true
        ls -la /dev/xvd* || true
        log "Error: Could not find EBS volume device"
        exit 1
    fi

    # Format and mount the volume
    log "Formatting $${DEVICE_NAME} with XFS"
    mkfs.xfs $${DEVICE_NAME}

    log "Creating mount point at $mount_path"
    mkdir -p "$mount_path"

    log "Mounting $${DEVICE_NAME} to $mount_path"
    mount $${DEVICE_NAME} "$mount_path"

    log "Adding to fstab"
    echo "$${DEVICE_NAME}  $mount_path  xfs  defaults  0  0" >> /etc/fstab
}

setup_clickhouse_server() {
    log "Setting up ClickHouse server..."

    # Install ClickHouse server and client
    apt-get install -y clickhouse-server clickhouse-client

    # Setup EBS volume for ClickHouse data
    setup_ebs_volume "/var/lib/clickhouse"
    chown -R clickhouse:clickhouse /var/lib/clickhouse

    # Copy configurations
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/cloudwatch.json" "$${CLOUDWATCH_CONFIG_PATH}"
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/config.d/" "$${CLICKHOUSE_CONFIG_DIR}" --recursive
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/users.xml" "/etc/clickhouse-server/users.xml"

    # Copy certificates and setup client config
    setup_certificates "server"
    setup_client_config "server"

    # Start service
    service clickhouse-server start
}

setup_clickhouse_keeper() {
    log "Setting up ClickHouse Keeper..."

    # Install only Keeper package
    apt-get install -y clickhouse-keeper

    # Setup EBS volume for Keeper data
    setup_ebs_volume "/var/lib/clickhouse-keeper"

    # Create required directories
    mkdir -p /var/lib/clickhouse-keeper
    mkdir -p /var/lib/clickhouse/coordination/log
    mkdir -p /var/lib/clickhouse/coordination/snapshots
    mkdir -p /var/log/clickhouse-keeper

    # Set ownership
    chown -R clickhouse:clickhouse /var/lib/clickhouse-keeper
    chown -R clickhouse:clickhouse /var/lib/clickhouse/coordination
    chown -R clickhouse:clickhouse /var/log/clickhouse-keeper

    # Set permissions
    chmod -R 750 /var/lib/clickhouse-keeper
    chmod -R 750 /var/lib/clickhouse/coordination
    chmod -R 750 /var/log/clickhouse-keeper

    # Copy configurations
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/cloudwatch.json" "$${CLOUDWATCH_CONFIG_PATH}"
    aws s3 cp "s3://${clickhouse_config_bucket}/${node_name}/keeper_config.xml" "$${KEEPER_CONFIG_PATH}"

    # Set keeper config permissions
    chown clickhouse:clickhouse "$${KEEPER_CONFIG_PATH}"
    chmod 640 "$${KEEPER_CONFIG_PATH}"

    # Copy certificates and setup client config if encryption enabled
    setup_certificates "keeper"
    setup_client_config "keeper"

    # Enable and start service
    systemctl enable clickhouse-keeper
    systemctl start clickhouse-keeper
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
        local cert_base_dir=""
        if [ "$1" = "server" ]; then
            cert_base_dir="/etc/clickhouse-server"
        elif [ "$1" = "keeper" ]; then
            cert_base_dir="/etc/clickhouse-keeper"
        else
            log "Invalid certificate type. Must be 'server' or 'keeper'."
            exit 1
        fi

        mkdir -p "$cert_base_dir"

        if [ "${use_external_certs}" = true ]; then
            echo "${external_ca_cert}" > "$cert_base_dir/ca.crt"

            log "Fetching node certificate materials from Secrets Manager"
            node_materials=$(aws secretsmanager get-secret-value \
                --secret-id "${node_secret_arn}" \
                --query SecretString \
                --output text)

            echo "$node_materials" | jq -r '.certificate' > "$cert_base_dir/server.crt"
            echo "$node_materials" | jq -r '.private_key' > "$cert_base_dir/server.key"
        else
            log "Fetching CA materials from Secrets Manager"
            ca_materials=$(aws secretsmanager get-secret-value \
                --secret-id "${ca_secret_arn}" \
                --query SecretString \
                --output text)

            echo "$ca_materials" | jq -r '.ca_certificate' > "$cert_base_dir/ca.crt"

            log "Fetching node certificate materials from Secrets Manager"
            node_materials=$(aws secretsmanager get-secret-value \
                --secret-id "${node_secret_arn}" \
                --query SecretString \
                --output text)

            echo "$node_materials" | jq -r '.certificate' > "$cert_base_dir/server.crt"
            echo "$node_materials" | jq -r '.private_key' > "$cert_base_dir/server.key"
        fi

        chown -R clickhouse:clickhouse "$cert_base_dir"
        chmod 600 "$cert_base_dir/server.key"
        chmod 644 "$cert_base_dir/server.crt" "$cert_base_dir/ca.crt"

        log "Certificate setup completed for $cert_base_dir"
    fi
}

setup_client_config() {
    if [ "${enable_encryption}" = true ]; then
        local cert_base_dir=""
        if [ "$1" = "server" ]; then
            cert_base_dir="/etc/clickhouse-server"
        elif [ "$1" = "keeper" ]; then
            cert_base_dir="/etc/clickhouse-keeper"
        else
            log "Invalid certificate type. Must be 'server' or 'keeper'."
            exit 1
        fi

        log "Setting up ClickHouse client configuration"
        mkdir -p /etc/clickhouse-client
        cp "$cert_base_dir/ca.crt" /etc/clickhouse-client/ca.crt

        cat > /etc/clickhouse-client/config.xml << EOF
<clickhouse>
    <openSSL>
        <client>
            <loadDefaultCAFile>false</loadDefaultCAFile>
            <caConfig>/etc/clickhouse-client/ca.crt</caConfig>
            <cacheSessions>true</cacheSessions>
            <disableProtocols>sslv2,sslv3</disableProtocols>
            <preferServerCiphers>true</preferServerCiphers>
            <invalidCertificateHandler>
                <name>RejectCertificateHandler</name>
            </invalidCertificateHandler>
        </client>
    </openSSL>
</clickhouse>
EOF

        chown -R clickhouse:clickhouse /etc/clickhouse-client
        chmod 644 /etc/clickhouse-client/config.xml
        chmod 644 /etc/clickhouse-client/ca.crt

        log "ClickHouse client configuration completed"
    fi
}

# Main script execution
trap 'handle_error $LINENO' ERR

log "Starting system setup..."
apt-get update
apt-get install -y jq

setup_ssm
install_aws_cli
setup_clickhouse_repo
install_cloudwatch_agent

if [ "${clickhouse_server}" = true ]; then
    setup_clickhouse_server
else
    setup_clickhouse_keeper
fi

start_cloudwatch_agent
log "Setup completed successfully!"
