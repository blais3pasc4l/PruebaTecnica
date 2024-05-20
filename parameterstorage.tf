resource "aws_ssm_parameter" "db_name" {
  name  = "db_name"
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "username" {
  name  = "username"
  type  = "String"
  value = var.username
}

resource "aws_ssm_parameter" "password" {
  name  = "password"
  type  = "String"
  value = var.password
}

locals {
  db_name_local_can  = aws_ssm_parameter.db_name.id != "" ? true : false
  username_local_can = aws_ssm_parameter.username.id != "" ? true : false
  password_local_can = aws_ssm_parameter.password.id != "" ? true : false
}