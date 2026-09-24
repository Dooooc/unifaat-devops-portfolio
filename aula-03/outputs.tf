output "developer_group" {
  value = aws_iam_group.developers.name
}

output "operations_group" {
  value = aws_iam_group.operations.name
}

output "readonly_group" {
  value = aws_iam_group.readonly.name
}

output "application_role" {
  value = aws_iam_role.application.name
}

output "developer_policy_arn" {
  value = aws_iam_policy.developer.arn
}

output "operations_policy_arn" {
  value = aws_iam_policy.operations.arn
}

output "readonly_policy_arn" {
  value = aws_iam_policy.readonly.arn
}