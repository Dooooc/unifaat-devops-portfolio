resource "aws_iam_user" "developer" {
  name = "technova-dev-alice"

  tags = local.common_tags
}

resource "aws_iam_user" "operations" {
  name = "technova-ops-bob"

  tags = local.common_tags
}

resource "aws_iam_user" "auditor" {
  name = "technova-auditor-carol"

  tags = local.common_tags
}

resource "aws_iam_user_group_membership" "developer" {
  user = aws_iam_user.developer.name

  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user_group_membership" "operations" {
  user = aws_iam_user.operations.name

  groups = [
    aws_iam_group.operations.name
  ]
}

resource "aws_iam_user_group_membership" "auditor" {
  user = aws_iam_user.auditor.name

  groups = [
    aws_iam_group.readonly.name
  ]
}