variable "db_name" {}
variable "db_engine" {}
variable "db_version" {}
variable "db_port" {}
variable "instance_class" { default = "db.t3.micro" }
variable "master_username" { default = "tf_rds_admin" }
variable "private_subnet_ids" {}
variable "public_subnet_id" {}
variable "security_group_id" {}