resource "aws_db_instance" "rds" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.r6g.2xlarge"
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true

}

resource "aws_db_subnet_group" "rds" {
  name       = "subnet_group"
  subnet_ids = [aws_subnet.private_subnet_zoneA.id, aws_subnet.private_subnet_zoneB.id]
}
