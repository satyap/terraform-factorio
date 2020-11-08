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
    aws_region       = var.region
    factorio_version = var.factorio_version
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

  # Initialise Factorio server settings, install systemd units.
  provisioner "remote-exec" {
    inline = [
      "sudo install -m 644 -o root -g root /tmp/factorio-environment -D -t /etc/factorio",
      "sudo install -m 644 -o root -g root /tmp/conf/server-settings.json /etc/factorio",
      "sudo install -m 644 -o root -g root /tmp/conf/server-adminlist.json /etc/factorio",
      "sudo install -m 644 -o root -g root /tmp/conf/factorio-headless.service /etc/systemd/system",
      "sudo install -m 644 -o root -g root /tmp/conf/factorio-backup.service /etc/systemd/system",
      "sudo install -m 644 -o root -g root /tmp/conf/factorio-restore.service /etc/systemd/system",
      "sudo systemctl daemon-reload",
    ]
  }
}
