###################
# SoftwareOne engineer role
###################

resource "aws_iam_role" "swo_engineer_access" {
  name               = "SWO-engineer"
  assume_role_policy = file("${path.module}/policies/swo_engineer_assume_role.json")

  tags = merge(
    {
      Name = local.swo_engineer_role_name
    },
    lookup(local.tags, "all_resources", {}),
  )
}

resource "aws_iam_role_policy_attachment" "swo_engineer_role_policy_attachment" {
  role       = aws_iam_role.swo_engineer_access.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

###################
# Local customer ReadOnly role
###################

resource "aws_iam_user" "customer_ro" {
  count = var.enable_customer_access ? 1 : 0
  name = var.customer_iam_user

  tags = merge(
    {
      Name = var.customer_iam_user
    },
    lookup(local.tags, "all_resources", {}),
  )
}

resource "aws_iam_group" "customer_ro" {
  count = var.enable_customer_access ? 1 : 0
  name  = "CustomerRO"
}

resource "aws_iam_group_policy" "customer_ro" {
  count = var.enable_customer_access ? 1 : 0
  name  = "CustomerRO-group-policy"
  group = aws_iam_group.customer_ro[0].name
  policy = templatefile("${path.module}/policies/basic_access_group_policy.tfpl", {
    account_id = data.aws_caller_identity.current.account_id, customer_acc = var.customer_iam_user
  })
}

resource "aws_iam_group_membership" "customer_ro" {
  count = var.enable_customer_access ? 1 : 0
  group = aws_iam_group.customer_ro[0].name
  name  = "CustomerRO"
  users = [ aws_iam_user.customer_ro[0].name ]
  depends_on = [
    aws_iam_user.customer_ro,
    aws_iam_group.customer_ro
  ]
}

resource "aws_iam_role" "customer_access" {
  count = var.enable_customer_access ? 1 : 0
  name               = "Customer-RO"
  assume_role_policy = templatefile("${path.module}/policies/customer_assume_role.tfpl", {
    account_id = data.aws_caller_identity.current.account_id, customer_acc = var.customer_iam_user
  })

  tags = merge(
    {
      Name = local.customer_role_name
    },
    lookup(local.tags, "all_resources", {}),
  )
}

resource "aws_iam_role_policy_attachment" "customer_role_policy_attachment" {
  count = var.enable_customer_access ? 1 : 0
  role       = aws_iam_role.customer_access[0].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}