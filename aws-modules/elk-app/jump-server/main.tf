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
data "aws_subnet" "public_subnet" {
  id = var.subnet_id
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "${terraform.workspace}-pub-key"
  public_key = file(var.public_key_path)

  tags = {
    Name = "${terraform.workspace}-pub-key"
  }
}



resource "aws_instance" "jump-server" {
  ami                         = data.aws_ami.ubuntu-24.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.public_subnet.id
  key_name                    = aws_key_pair.ssh-key.key_name
  vpc_security_group_ids      = [aws_security_group.default_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_eks_access_profile.name

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "${terraform.workspace}-elk-jump-server"
  }
}