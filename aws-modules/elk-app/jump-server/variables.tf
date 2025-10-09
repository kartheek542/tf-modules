variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "allowed_ports" {
  default = [443, 80, 22]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "subnet_id" { }
variable "eks_cluster_arn" { }