data "aws_ami" "managed" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20200304.?-x86_64-gp2"]
  }

  most_recent = true
  owners      = ["amazon"]
}

data "template_file" "cloud_config" {
  template = file("./cloud-config.yml")
  vars = {
    factorio_version = var.factorio_version
    s3_bucket        = aws_s3_bucket.backup.id
  }
}

resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "factorio" {
  vpc_id = aws_default_vpc.default.id
  name   = "${var.name}-security-group"
  tags   = var.tags

  ingress {
    protocol    = "udp"
    from_port   = 34197
    to_port     = 34197
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "factorio" {
  ami                         = data.aws_ami.managed.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  tags                        = var.tags

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  iam_instance_profile = aws_iam_instance_profile.backup.id

  user_data       = data.template_file.cloud_config.rendered
  security_groups = [aws_security_group.factorio.name]
}
