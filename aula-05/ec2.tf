# ============================================================
# KEY PAIR — AWS Academy usa "vockey" pre-existente
# O Academy nao permite criar novos key pairs via Terraform.
# Usamos data source para referenciar o vockey existente.
# Para SSH: baixe labsuser.pem em "AWS Details" no Academy.
# ============================================================

data "aws_key_pair" "vockey" {
  key_name = "vockey"
}

# ============================================================
# INSTANCIA EC2 -- subnet publica, com psql instalado
# user_data via templatefile para evitar conflito entre
# interpolacoes Terraform (${ }) e sintaxe Bash ($( ))
# ============================================================

resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = data.aws_key_pair.vockey.key_name
  iam_instance_profile   = data.aws_iam_instance_profile.lab_instance_profile.name

  # templatefile renderiza user_data.tpl substituindo as variaveis Terraform
  # sem conflito com sintaxe bash $(date), $(command), etc.
  user_data = templatefile("${path.module}/user_data.tpl", {
    rds_endpoint = aws_db_instance.technova.address
    db_port      = tostring(var.db_port)
    db_name      = var.db_name
    db_user      = var.db_username
    db_password  = var.db_password
  })

  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name    = "${local.name_prefix}-ec2-root-volume"
      Project = "TechNova"
      Aula    = "05"
    }
  }

  tags = {
    Name    = "${local.name_prefix}-ec2-api"
    Tier    = "public"
    Role    = "api-server"
    Project = "TechNova"
    Aula    = "05"
  }

  # IGW e RDS devem existir antes do EC2
  depends_on = [
    aws_internet_gateway.technova,
    aws_db_instance.technova,
  ]
}