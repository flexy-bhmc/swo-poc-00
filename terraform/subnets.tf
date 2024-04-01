#################
# Public subnet #
#################

locals {
  number_of_subnets = length(keys(var.public_subnets))
}

resource "aws_subnet" "public" {
  for_each = var.create_vpc && length(var.public_subnets) > 0 ? local.reversed_public_subnets : {}

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.key
  availability_zone = element(each.value, 0)

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${local.public_subnets_name}-${join("-", slice(split(".", each.key), 0, 3))}"
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "subnets", {}),
    lookup(local.tags, "subnet_public", {})
  )
}

##################
# Private subnet #
##################
resource "aws_subnet" "private" {
  for_each = var.create_vpc && length(var.private_subnets) > 0 ? local.reversed_private_subnets : {}

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.key
  availability_zone = element(each.value, 0)


  tags = merge(
    {
      Name = "${local.private_subnets_name}-${join("-", slice(split(".", each.key), 0, 3))}"
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "subnets", {}),
    lookup(local.tags, "subnet_private", {})
  )
}

###################
# Database subnet #
###################
resource "aws_subnet" "database" {
  for_each = var.create_vpc && length(var.database_subnets) > 0 ? local.reversed_database_subnets : {}

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = each.key
  availability_zone = element(each.value, 0)


  tags = merge(
    {
      Name = "${local.database_subnets_name}-${join("-", slice(split(".", each.key), 0, 3))}"
    },
    lookup(local.tags, "all_resources", {}),
    lookup(local.tags, "subnets", {}),
    lookup(local.tags, "subnet_database", {})
  )
}