resource "aws_iam_policy" "developer" {
  name        = "TechNovaDeveloperPolicy"
  description = "Permissões mínimas necessárias para desenvolvedores"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::technova-development",
          "arn:aws:s3:::technova-development/*"
        ]
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "developer" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer.arn
}

resource "aws_iam_policy" "operations" {
  name        = "TechNovaOperationsPolicy"
  description = "Permissões operacionais controladas da TechNova"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSecurityGroups",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "operations" {
  group      = aws_iam_group.operations.name
  policy_arn = aws_iam_policy.operations.arn
}

resource "aws_iam_policy" "readonly" {
  name        = "TechNovaReadOnlyPolicy"
  description = "Permissões somente leitura para auditoria"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:Describe*",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
          "s3:GetObject",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "readonly" {
  group      = aws_iam_group.readonly.name
  policy_arn = aws_iam_policy.readonly.arn
}