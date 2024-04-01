#################
# Publiс routes #
#################
resource "aws_route_table" "public" {
  for_each = var.create_vpc && length(var.public_subnets) > 0 ? local.public_subnets : {}

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.public_route_table_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "route_tables", {}),
    lookup(local.tags, "route_table_public", {})
  )
}

resource "aws_route" "public_internet_gateway" {
  for_each = var.create_vpc && length(var.public_subnets) > 0 ? local.public_subnets : {}

  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "static_public_route" {
  count                  = var.create_vpc && length(var.public_subnets) > 0 && var.public_static_routes != null ? length(var.public_static_routes) : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = var.public_static_routes[count.index]
  gateway_id             = aws_internet_gateway.this[0].id
}

##################################################################
#                     Private routes                             #
# There are as many routing tables as the number of NAT gateways #
##################################################################
resource "aws_route_table" "private" {
  for_each = var.create_vpc && length(var.private_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? local.private_subnets : local.one_nat_private_subnets : {}

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.private_route_table_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "route_tables", {}),
    lookup(local.tags, "route_table_private", {})
  )
}

resource "aws_route" "private_nat_gateway" {
  for_each = var.create_vpc && var.attach_nat_gateway_to_rt && var.enable_nat_gateway ? var.nat_gateway_per_az ? local.private_subnets : local.one_nat_private_subnets : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id

  timeouts {
    create = "5m"
  }
}

###################
# Database routes #
###################
resource "aws_route_table" "database" {
  for_each = var.create_vpc && length(var.database_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? local.database_subnets : local.one_nat_database_subnets : {}

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    {
      Name = local.database_route_table_name
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "route_tables", {}),
    lookup(local.tags, "route_table_tgw", {})
  )
}

resource "aws_route" "database_nat_gateway" {
  for_each = var.create_vpc && var.attach_nat_gateway_to_rt && var.enable_nat_gateway ? var.nat_gateway_per_az ? local.database_subnets : local.one_nat_database_subnets : {}

  route_table_id         = aws_route_table.database[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  for_each = var.create_vpc && length(var.public_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? { for subnet in aws_subnet.public : subnet.cidr_block => subnet.availability_zone } : { for subnet in aws_subnet.public : subnet.cidr_block => keys(local.public_subnets)[0] } : {}

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.value].id
}

resource "aws_route_table_association" "private" {
  for_each = var.create_vpc && length(var.private_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? { for subnet in aws_subnet.private : subnet.cidr_block => subnet.availability_zone } : { for subnet in aws_subnet.private : subnet.cidr_block => keys(local.private_subnets)[0] } : {}

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.value].id
}

resource "aws_route_table_association" "database" {
  for_each = var.create_vpc && length(var.database_subnets) > 0 ? var.enable_nat_gateway && var.nat_gateway_per_az ? { for subnet in aws_subnet.database : subnet.cidr_block => subnet.availability_zone } : { for subnet in aws_subnet.database : subnet.cidr_block => keys(local.database_subnets)[0] } : {}

  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[each.value].id
}