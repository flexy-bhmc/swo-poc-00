output "vpc_id" {
  description = "The ID of the VPC"
  value       = concat(aws_vpc.this[*].id, [""])[0]
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = concat(aws_vpc.this[*].arn, [""])[0]
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = concat(aws_vpc.this[*].cidr_block, [""])[0]
}

output "vpc_flowlogs" {
  description = "The name of the VPC flowlogs CW LogGroup"
  value       = concat(aws_flow_log.vpc_flow_log[*].log_group_name, [""])[0]
}

output "vpc_flowlogs_role_arn" {
  description = "The name of the VPC flowlogs role"
  value       = var.flowlogs_role_name == "" ? try(aws_iam_role.vpc_flowlogs_role[0].arn, null) : null
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = concat(aws_vpc.this[*].default_security_group_id, [""])[0]
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = concat(aws_vpc.this[*].main_route_table_id, [""])[0]
}

# ---------------------------
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.arn]
}

output "public_subnets_cidr" {
  description = "MAP of IDs of public subnets and coresponding cidr"
  value       = { for subnet in aws_subnet.public : subnet.cidr_block => subnet.id }
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.cidr_block]
}

output "public_route_table_id" {
  description = "List of IDs of public route tables"
  value       = [for rt_public in aws_route_table.public : rt_public.id]
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "private_subnets_cidr" {
  description = "MAP of IDs of private subnets and coresponding cidr"
  value       = { for subnet in aws_subnet.private : subnet.cidr_block => subnet.id }
}

output "private_route_table_id" {
  description = "ID of private route table"
  value       = [for rt_private in aws_route_table.private : rt_private.id]
}

output "database_subnet_ids" {
  description = "List of IDs of Database subnets"
  value       = [for subnet in aws_subnet.database : subnet.id]
}

output "database_subnets_cidr" {
  description = "MAP of IDs of database subnets and coresponding cidr"
  value       = { for subnet in aws_subnet.database : subnet.cidr_block => subnet.id }
}

output "database_route_table_id" {
  description = "ID of database route table"
  value       = [for rt_database in aws_route_table.database : rt_database.id]
}

# ---------------------------
# output "nat_ids" {
#   description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
#   value       = [for nat_ids in aws_eip.nat : nat_ids.id]
# }
# output "nat_public_ips" {
#   description = "List of public Elastic IPs created for AWS NAT Gateway"
#   value       = [for nat_public_ips in aws_eip.nat : nat_public_ips.public_ip]
# }

# output "natgw_ids" {
#   description = "List of NAT Gateway IDs"
#   value       = [for natgw_ids in aws_nat_gateway.this : natgw_ids.id]
# }

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = concat(aws_internet_gateway.this[*].id, [""])[0]
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = concat(aws_vpc.this[*].default_network_acl_id, [""])[0]
}

