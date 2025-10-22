variable "cluster_subnet_ids" {}
variable "pods_ip_cidr" { default = "192.168.0.0/16" }
variable "cluster_version" { default = "1.30" }
variable "security_group_ids" {}
variable "node_groups" {
  default = [{
    name          = "group-1"
    instance_type = "t3.medium"
    disk_size     = 30
    group_size    = 2
    }
  ]
}
variable "namespace" { default = "elk-kar" }
variable "service_account" { default = "kar-aws" }