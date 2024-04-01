locals {
    account_id = data.aws_caller_identity.current.account_id
}

locals {
  public_subnets   = { for az, cidr in var.public_subnets : "${local.region}${az}" => cidr }
  private_subnets  = { for az, cidr in var.private_subnets : "${local.region}${az}" => cidr }
  database_subnets = { for az, cidr in var.database_subnets : "${local.region}${az}" => cidr }
}

locals {
  reversed_public_subnets   = transpose(local.public_subnets)
  reversed_private_subnets  = transpose(local.private_subnets)
  reversed_database_subnets = transpose(local.database_subnets)
}

locals {
  one_nat_private_subnets  = length(var.private_subnets) > 0 ? zipmap([keys(local.private_subnets)[0]], [values(local.private_subnets)[0]]) : {}
  one_nat_database_subnets = length(var.database_subnets) > 0 ? zipmap([keys(local.database_subnets)[0]], [values(local.database_subnets)[0]]) : {}
}

locals {
  tags   = merge({}, var.tags)
  region = coalesce(var.region, data.aws_region.current.name)
}

locals {
  vpc_name                   = "${var.global_prefix["vpc"]}"
  eip_name                   = "${var.global_prefix["eip"]}"
  public_subnets_name        = "${var.global_prefix["subnets"]}-public"
  private_subnets_name       = "${var.global_prefix["subnets"]}-private"
  database_subnets_name      = "${var.global_prefix["subnets"]}-db"
  public_route_table_name    = "${var.global_prefix["route_table"]}-public"
  private_route_table_name   = "${var.global_prefix["route_table"]}-private"
  database_route_table_name  = "${var.global_prefix["route_table"]}-db-vpc"
  internet_gateway_name      = "${var.global_prefix["internet_gateway"]}"
  dhcp_options_name          = "${var.global_prefix["dhcp_options"]}"
  nat_gateway_name           = "${var.global_prefix["nat_gateway"]}"
  vpc_cloudwatch_log_group_name = "${var.global_prefix["vpc_flowlogs"]}"
  vpc_flow_log_name             = "${var.global_prefix["vpc_flowlogs"]}"
  vpc_flow_log_role_name        = "${var.global_prefix["vpc_flowlogs"]}-iam-role"
  vpc_flow_log_policy_name      = "${var.global_prefix["vpc_flowlogs"]}-iam-policy"
}

locals {
  swo_engineer_role_name        = "${var.global_prefix["swo_engineer_acc"]}-iam-role"
  swo_engineer_policy_name      = "${var.global_prefix["swo_engineer_acc"]}-iam-policy"
  customer_role_name            = "${var.global_prefix["customer_acc"]}-iam-role"
  customer_policy_name          = "${var.global_prefix["customer_acc"]}-iam-policy"
}