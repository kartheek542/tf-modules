data "aws_region" "current" {}
data "aws_ami" "ubuntu-24" {
  most_recent = true
  region      = data.aws_region.current.region

  filter {
    name   = "name"
    values = ["ubuntu/*24.04*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  // Amazon owner
  owners = ["099720109477"]

}

resource "aws_key_pair" "ssh-key" {
  key_name   = "${terraform.workspace}-pub-key"
  public_key = file(var.public_key_path)

  tags = {
    Name = "${terraform.workspace}-pub-key"
  }
}



resource "aws_instance" "app-server" {
  ami                    = data.aws_ami.ubuntu-24.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.ssh-key.key_name
  vpc_security_group_ids = [var.security_group_id]
  private_ip             = cidrhost(data.aws_subnet.public_subnet.cidr_block, 5)
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name = "${terraform.workspace}-elk-app-server"
  }
}