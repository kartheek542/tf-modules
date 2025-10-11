resource "aws_key_pair" "ssh-key" {
  key_name   = "${terraform.workspace}-${var.name}"
  public_key = file(var.public_key_path)

  tags = {
    Name = "${terraform.workspace}-${var.name}"
  }
}
