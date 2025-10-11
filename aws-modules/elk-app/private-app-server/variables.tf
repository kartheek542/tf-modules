variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "subnet_id" {}

variable "allowed_ranges" {}

variable "security_group_id" {}