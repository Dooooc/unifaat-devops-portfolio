# ============================================================
# IAM — AWS Academy Learner Lab
#
# O ambiente do Academy nao permite iam:CreateRole.
# A role "LabRole" e o instance profile "LabInstanceProfile"
# ja existem na conta e possuem as permissoes necessarias,
# incluindo AmazonS3ReadOnlyAccess.
#
# Usamos data sources para referenciar os recursos existentes
# em vez de tentar criar novos.
# ============================================================

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_iam_instance_profile" "lab_instance_profile" {
  name = "LabInstanceProfile"
}
