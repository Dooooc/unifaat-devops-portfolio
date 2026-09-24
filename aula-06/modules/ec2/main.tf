# ============================================================
# Modulo EC2 — instancia configuravel com AMI, SG e subnet
# ============================================================

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  user_data                   = var.user_data != "" ? var.user_data : null
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name        = "${var.instance_name}-root-volume"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Name        = var.instance_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}