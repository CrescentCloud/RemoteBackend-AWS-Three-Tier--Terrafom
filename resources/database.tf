# --- database/main.tf ---

resource "aws_db_instance" "awsprod_db" {
  allocated_storage      = var.db_storage
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.dbuser
  password               = var.dbpassword
  db_subnet_group_name   = var.db_subnet_group_name
  identifier             = var.db_identifier
  skip_final_snapshot    = var.skip_db_snapshot
  vpc_security_group_ids = [var.rds_sg]

  tags = {
    Name = "aws-prod-db"
  }
}

# --- database/outputs.tf ---

output "db_endpoint" {
  value = aws_db_instance.awsprod_db.endpoint
}

# --- database/variables.tf ---

variable "db_storage" {}
variable "db_instance_class" {}
variable "db_name" {}
variable "dbuser" {}
variable "dbpassword" {}
variable "db_subnet_group_name" {}
variable "db_engine_version" {}
variable "db_identifier" {}
variable "skip_db_snapshot" {}
variable "rds_sg" {}