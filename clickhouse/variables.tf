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

############
# Bastion  #
############
variable "enable_bastion" {
  type        = bool
  description = "Whether to deploy a bastion host"
  default     = false
}
