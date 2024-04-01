variable "tf_state_bucket" {
  description = "Set Terraform state bucket name."
  type        = string
  default     = "627935236173-tf-state"
}

variable "region" {
  description = "The AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "enable_customer_access" {
  description = "Should be false if you don't want to grant access to a new customer user"
  type        = bool
  default     = false
}

variable "customer_iam_user" {
  description = "Username that will be provided for validation"
  type        = string
  default     = "UserX"
}

variable "create_vpc" {
  description = "Should be false if you want skip VPC creation"
  type        = bool
  default     = true
}

variable "global_prefix" {
  description = "Global prefix used to construct resource names"
  type        = map(string)
  default = {
    eip              = "poc-nat-eip"
    nat_gateway      = "poc-nat"
    internet_gateway = "poc-igw"
    route_table      = "poc-rt"
    subnets          = "poc-sub"
    vpc              = "poc-vpc"
    dhcp_options     = "poc-dhcp-opt"
    cw_loggrp        = "poc-vpc-flow-log"
    vpc_flowlogs     = "poc-vpc-flow-log"
#    vpc_flowlogs_iam_role         = "poc-vpc-flow-log-iam-role"
#    vpc_flowlogs_iam_policy       = "poc-vpc-flow-log-iam-policy"
    swo_engineer_acc = "poc-swo-engineer"
    customer_acc     = "poc-customer"
  }
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "192.0.2.0/24"  # NOT PUBLICLY ROUTABLE CIDR!!! This range is reserved for documentation and example purposes according to RFC 5737, so it's highly unlikely to be used in a real-world network. Used in order to minimize the chance of overlapping when testing.
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "public_subnets" {
  description = "Map from availability zone to the list of subnets corresponding to that AZ"
  type        = map(list(string))
  default     = {
    a = ["192.0.2.0/27"],
    b = ["192.0.2.32/27"]
  }
}

variable "private_subnets" {
  description = "Map from availability zone to the list of subnets corresponding to that AZ"
  type        = map(list(string))
  default     = {
    a = ["192.0.2.64/27"],
    b = ["192.0.2.96/27"]
  }
}

variable "database_subnets" {
  description = "Map from availability zone to the list of subnets corresponding to that AZ"
  type        = map(list(string))
  default     = {
    a = ["192.0.2.128/27"],
    b = ["192.0.2.160/27"]
  }
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "nat_gateway_per_az" {
  description = "Should be false if you want only one NAT Gateway"
  type        = bool
  default     = true
}

variable "attach_nat_gateway_to_rt" {
  description = "Should be true if you want to attach the NAT Gateway to the private route table."
  type        = bool
  default     = false
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(map(string))
  default     = {}
}

variable "vpc_cloudwatch_log_group_retention" {
  description = "VPC flow logs in CloudWatch logGroup retention in days"
  type        = number
  default     = 90
}

variable "flowlogs_role_name" {
  description = "VPC flowlog role name if passed externaly"
  type        = string
  default     = ""
}

# ---------------------------
# DHCP options
variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

##############################################
variable "public_static_routes" {
  description = "static routes needed in the public route table"
  type        = list(string)
  default     = null
}

variable "create_vpc_log_group" {
  description = "Control whether to explicitly create log group or leave to be created by the service"
  type        = bool
  default     = true
}

variable "is_primary_region" {
  description = "Indicates if this is a primary or secondary region"
  type        = bool
  default     = true
}

variable "flow_log_bucket_arn" {
  description = "Bucket to ingest flow logs"
  type        = string
  default     = ""
}

variable "log_format" {
  description = "VPC flow log format"
  type        = string
  default     = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
}

variable "traffic_type" {
  description = "VPC traffic type"
  type        = string
  default     = "ALL"
}

variable "enable_flow_logs" {
  description = "Enable/disable vpc flow logs creation "
  type        = bool
  default     = true
}
