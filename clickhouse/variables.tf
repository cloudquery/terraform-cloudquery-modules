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
  description = "The size of the EBS volume for the ClickHouse servers"
  default     = 10
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
  description = "The size of the EBS volume for the ClickHouse keepers"
  default     = 10
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