###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.internet_gateway_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "internet_gateways", {}),
    lookup(local.tags, "internet_gateway", {})
  )
}

##############
# NAT Gateway
##############

# Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
# Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
#
# The logical expression would be
#
#    nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat.*.id
#
# but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
locals {
  # tflint-ignore: terraform_unused_declarations
  nat_gateway_ips = split(",", var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", [for nat_id in aws_eip.nat : nat_id.id]))
  one_nat         = length(var.public_subnets) > 0 ? zipmap([keys(local.public_subnets)[0]], [values(local.public_subnets)[0]]) : {}
}

resource "aws_eip" "nat" {
  for_each = var.create_vpc && var.enable_nat_gateway && false == var.reuse_nat_ips ? var.nat_gateway_per_az ? local.public_subnets : local.one_nat : {}
  domain = "vpc"
  tags = merge(
    {
      Name = local.eip_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "aws_eips", {}),
    lookup(local.tags, "aws_eip", {})
  )
}

resource "aws_nat_gateway" "this" {
  for_each = var.create_vpc && var.enable_nat_gateway ? var.nat_gateway_per_az ? local.public_subnets : local.one_nat : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.value[0]].id

  tags = merge(
    {
      Name = local.nat_gateway_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "nat_gateways", {}),
    lookup(local.tags, "nat_gateway", {})
  )

  depends_on = [aws_internet_gateway.this]
}