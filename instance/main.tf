terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region  = var.region
  version = "~> 2.13"
}

provider "template" {
  version = "~> 2.1"
}

provider "tls" {
  version = "~> 2.1"
}

provider "null" {
  version = "~> 2.1"
}

locals {
  # To load named save game: --start-server ${path}/${name}.zip
  # To load latest save game: --start-server-load-latest
  save_game_arg = (var.factorio_save_game != "" ?
    "--start-server ${var.factorio_save_game}.zip'" :
  "--start-server-load-latest")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "cloud_config" {
  template = file("./cloud-config.yml")
  vars = {
    aws_region       = var.region
    factorio_version = var.factorio_version
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key" {
  key_name   = var.name
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_default_vpc" "default" {
}

resource "aws_instance" "factorio" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  tags                        = var.tags

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  iam_instance_profile = aws_iam_instance_profile.backup.id

  key_name        = aws_key_pair.key.key_name
  user_data       = data.template_file.cloud_config.rendered
  security_groups = [aws_security_group.instance.name]

  provisioner "file" {
    source      = "conf"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = <<ENV
S3_BUCKET=${aws_s3_bucket.backup.bucket}
SAVE_GAME_ARG=${local.save_game_arg}
ENV
    destination = "/tmp/factorio-environment"
  }

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
