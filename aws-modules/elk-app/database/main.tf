data "aws_rds_engine_version" "database" {
  engine  = var.db_engine
  version = var.db_version
}

resource "aws_db_parameter_group" "elk-params-group" {
  name   = "elk-params-group"
  family = data.aws_rds_engine_version.database.parameter_group_family

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${terraform.workspace}-elk-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${terraform.workspace}-elk-db-subnet-group"
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage           = 10
  db_name                     = var.db_name
  engine                      = data.aws_rds_engine_version.database.engine
  engine_version              = data.aws_rds_engine_version.database.version
  port                        = var.db_port
  username                    = var.master_username
  manage_master_user_password = true
  instance_class              = var.instance_class
  parameter_group_name        = aws_db_parameter_group.elk-params-group.name
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids      = [aws_security_group.database_sg.id]
  skip_final_snapshot         = true
}