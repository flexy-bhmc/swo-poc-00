######
# VPC
######
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      Name = local.vpc_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "vpcs", {}),
    lookup(local.tags, "vpc_this", {})
  )
}

resource "aws_default_security_group" "this" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = "vpc-default-sg"
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "security_groups", {}),
    lookup(local.tags, "security_group_default", {})
  )
}

resource "aws_default_network_acl" "this" {
  count                  = var.create_vpc ? 1 : 0
  default_network_acl_id = aws_vpc.this[0].default_network_acl_id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "192.168.0.0/16"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "192.168.0.0/16"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "172.16.0.0/12"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 150
    action     = "allow"
    cidr_block = "172.16.0.0/12"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 32750
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 32760
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = -1
    rule_no    = 32766
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 32766
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    {
      Name = local.dhcp_options_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "dhcp_options", {}),
    lookup(local.tags, "dhcp_options_this", {})
  )
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this[0].id
  dhcp_options_id = aws_vpc_dhcp_options.this[count.index].id
}

################
# VPC flow logs
################

resource "aws_flow_log" "vpc_flow_log" {
  count = var.create_vpc && var.flow_log_bucket_arn == "" && var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.this[count.index].id
  iam_role_arn    = var.flowlogs_role_name != "" ? var.flowlogs_role_name : aws_iam_role.vpc_flowlogs_role[count.index].arn
  log_destination = try(aws_cloudwatch_log_group.vpc_log_group[count.index].arn, "arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.vpc_cloudwatch_log_group_name}")
  traffic_type    = var.traffic_type
  log_format      = var.log_format

  tags = merge(
    {
      Name = local.vpc_flow_log_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "flow_logs", {}),
    lookup(local.tags, "flow_log_vpc", {})
  )
}

resource "aws_flow_log" "vpc_flow_log_s3" {
  count = var.create_vpc && var.flow_log_bucket_arn != "" && var.enable_flow_logs ? 1 : 0

  vpc_id               = aws_vpc.this[count.index].id
  log_destination_type = "s3"
  log_destination      = var.flow_log_bucket_arn
  traffic_type         = var.traffic_type
  log_format           = var.log_format

  tags = merge(
    {
      Name = local.vpc_flow_log_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "flow_logs", {}),
    lookup(local.tags, "flow_log_vpc", {})
  )
}

#tfsec:ignore:AWS089
resource "aws_cloudwatch_log_group" "vpc_log_group" {
  count = var.create_vpc && var.create_vpc_log_group && var.flow_log_bucket_arn == "" && var.enable_flow_logs ? 1 : 0

  name              = local.vpc_cloudwatch_log_group_name
  retention_in_days = var.vpc_cloudwatch_log_group_retention

  tags = merge(
    {
      Name = local.vpc_cloudwatch_log_group_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "log_groups", {}),
    lookup(local.tags, "log_group_vpc", {})
  )

}

resource "aws_iam_role" "vpc_flowlogs_role" {
  count = var.is_primary_region && var.create_vpc && var.flowlogs_role_name == "" && var.flow_log_bucket_arn == "" && var.enable_flow_logs ? 1 : 0

  name               = local.vpc_flow_log_role_name
  assume_role_policy = file("${path.module}/policies/vpc_flow_logs_assume_role.json")

  tags = merge(
    {
      Name = local.vpc_flow_log_role_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "iam_roles", {}),
    lookup(local.tags, "iam_role_nw_vpc_fw", {})
  )
}


resource "aws_iam_role_policy" "vpc_flowlogs_policy" {
  count = var.is_primary_region && var.create_vpc && var.flowlogs_role_name == "" && var.flow_log_bucket_arn == "" && var.enable_flow_logs ? 1 : 0

  name = local.vpc_flow_log_policy_name
  role = aws_iam_role.vpc_flowlogs_role[count.index].id

  policy = file("${path.module}/policies/vpc_flow_logs_policy.json")
}
