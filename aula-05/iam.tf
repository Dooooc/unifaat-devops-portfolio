# ============================================================
# IAM — AWS Academy Learner Lab
#
# O Academy não permite iam:CreateRole.
# A role "LabRole" e o instance profile "LabInstanceProfile"
# já existem na conta e possuem as permissões necessárias
# (S3, DynamoDB, EC2, RDS, etc.).
#
# Usamos data sources para referenciar os recursos existentes.
# ============================================================

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_iam_instance_profile" "lab_instance_profile" {
  name = "LabInstanceProfile"
}
