# ============================================================
# DYNAMODB — LOCK DO TERRAFORM STATE
# ============================================================

resource "aws_dynamodb_table" "tfstate_lock" {
  name         = var.state_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  deletion_protection_enabled = false

  tags = {
    Name    = var.state_dynamodb_table
    Purpose = "Terraform State Locking"
    Project = "TechNova"
    Aula    = "05"
  }
}
