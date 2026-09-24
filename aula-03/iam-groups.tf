resource "aws_iam_group" "developers" {
  name = "technova-developers"
}

resource "aws_iam_group" "operations" {
  name = "technova-ops"
}

resource "aws_iam_group" "readonly" {
  name = "technova-readonly"
}