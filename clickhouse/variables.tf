#####################
# AWS Configuration #
#####################
variable "region" {
  type        = string
  description = "The AWS region to deploy to"
  default     = "us-west-2"
}

##############
# ClickHouse #
##############
variable "cluster_name" {
  type        = string
  description = "The name of the ClickHouse cluster"
  default     = "clickhouse_cluster"
}

variable "cluster_node_count" {
  type        = number
  description = "The number of ClickHouse servers to deploy"
  default     = 3
}

variable "keeper_node_count" {
  type        = number
  description = "The number of ClickHouse keepers to deploy"
  default     = 3
  validation {
    condition     = var.keeper_node_count % 2 == 1
    error_message = "keeper_node_count must be an odd number"
  }
}

variable "clickhouse_instance_type" {
  type        = string
  description = "The instance type for the ClickHouse servers"
  default     = "t2.medium"
}

variable "clickhouse_volume_size" {
  type        = number
  description = "The size of the EBS volume for the ClickHouse servers in GB"
  default     = 10

  validation {
    condition     = var.clickhouse_volume_size >= 10
    error_message = "Volume size must be at least 10 GB"
  }
}

variable "clickhouse_volume_type" {
  type        = string
  description = "The type of EBS volume for the ClickHouse servers"
  default     = "gp2"
}

variable "keeper_instance_type" {
  type        = string
  description = "The instance type for the ClickHouse keepers"
  default     = "t2.medium"
}

variable "keeper_volume_size" {
  type        = number
  description = "The size of the EBS volume for the ClickHouse keepers in GB"
  default     = 10

  validation {
    condition     = var.keeper_volume_size >= 10
    error_message = "Volume size must be at least 10 GB"
  }
}

variable "keeper_volume_type" {
  type        = string
  description = "The type of EBS volume for the ClickHouse keepers"
  default     = "gp2"
}

variable "enable_nlb" {
  type        = bool
  description = "Enable the Network Load Balancer for the ClickHouse cluster"
  default     = true
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the ClickHouse cluster"
  default     = ["0.0.0.0/0"] # Default to allow all, but users should override this
  validation {
    condition     = length(var.allowed_cidr_blocks) > 0
    error_message = "At least one CIDR block must be specified"
  }
}

variable "default_user_networks" {
  type        = list(string)
  description = "List of networks allowed to connect as default user"
  default     = ["::/0"] # Allow from anywhere by default
}

variable "admin_user_networks" {
  type        = list(string)
  description = "List of networks allowed to connect as admin user"
  default     = ["::/0"] # Allow from anywhere by default
}

variable "shards" {
  type = list(object({
    replica_count = number
    weight        = optional(number, 1)
  }))
  description = "List of shards and their configuration. Each shard specifies how many replicas it should have and optionally its weight."

  validation {
    condition     = length(var.shards) > 0
    error_message = "At least one shard must be configured"
  }

  validation {
    condition     = alltrue([for shard in var.shards : shard.replica_count > 0])
    error_message = "Each shard must have at least one replica"
  }
}

variable "enable_encryption" {
  type        = bool
  description = "Enable TLS encryption for all ClickHouse communication"
  default     = false
}

variable "nlb_type" {
  type        = string
  description = "Type of NLB to create - internal or external"
  default     = "internal"
  validation {
    condition     = contains(["internal", "external"], var.nlb_type)
    error_message = "nlb_type must be either 'internal' or 'external'"
  }
}

variable "tls_certificate_arn" {
  type        = string
  description = "ARN of ACM certificate to use for TLS. Required when enable_encryption is true and use_self_signed_cert is false"
  default     = ""
}

variable "cluster_domain" {
  type        = string
  description = "Domain name for the cluster (used for certificates)"
  default     = ""
}

# Optional: Allow custom security settings
variable "ssl_cert_days" {
  type        = number
  description = "Validity period for self-signed certificates in days"
  default     = 365
}

variable "ssl_key_bits" {
  type        = number
  description = "Key size for self-signed certificates"
  default     = 2048
}

# HTTP Ports
variable "http_port" {
  type        = number
  description = "HTTP default port"
  default     = 8123
}

variable "https_port" {
  type        = number
  description = "HTTPS default port"
  default     = 8443
}

# TCP Protocol Ports
variable "tcp_port" {
  type        = number
  description = "Native Protocol port for client-server communication"
  default     = 9000
}

variable "tcp_port_secure" {
  type        = number
  description = "Native protocol SSL/TLS port"
  default     = 9440
}

# Inter-server Communication Ports
variable "interserver_http_port" {
  type        = number
  description = "Inter-server communication port"
  default     = 9009
}

variable "interserver_https_port" {
  type        = number
  description = "SSL/TLS port for inter-server communications"
  default     = 9010
}

# Keeper Ports
variable "keeper_port" {
  type        = number
  description = "ClickHouse Keeper port"
  default     = 9181
}

variable "keeper_port_secure" {
  type        = number
  description = "Secure SSL ClickHouse Keeper port"
  default     = 9281
}

variable "keeper_raft_port" {
  type        = number
  description = "ClickHouse Keeper Raft port"
  default     = 9234
}

# Prometheus Metrics Port
variable "prometheus_port" {
  type        = number
  description = "Prometheus metrics port"
  default     = 9363
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

variable "retention_period" {
  type        = number
  description = "Log retention period in days"
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.retention_period)
    error_message = "Retention period must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653"
  }
}

variable "key_name" {
  type        = string
  description = "Name of an AWS key pair to use for SSH access (must exist in the AWS account)"
  default     = "" # Empty string means no key pair will be used
}

variable "ssh_access" {
  type = object({
    enabled = bool
    # cidr_blocks can be null to use VPC CIDR, or a list of explicit CIDRs
    cidr_blocks = list(string)
    # if true, adds VPC CIDR to the provided cidr_blocks
    include_vpc_cidr = bool
  })
  description = "SSH access configuration. Set enabled=false to disable SSH access, or configure cidr_blocks for access control."
  default = {
    enabled          = false
    cidr_blocks      = []
    include_vpc_cidr = true
  }

  validation {
    condition     = var.ssh_access.enabled == false || length(var.ssh_access.cidr_blocks) > 0 || var.ssh_access.include_vpc_cidr
    error_message = "When SSH access is enabled, either cidr_blocks must be provided or include_vpc_cidr must be true"
  }
}
