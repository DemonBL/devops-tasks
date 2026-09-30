packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

locals {
  ts = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  region        = var.region
  instance_type = "t3.micro"
  ami_name      = "hardened-ubuntu-2404-${local.ts}"
  ssh_username  = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical
    most_recent = true
  }

  tags = {
    Name      = "hardened-ubuntu-2404"
    BuiltWith = "packer+ansible"
    Hardening = "dev-sec/os_hardening"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo cloud-init status --wait || true",
      "sudo apt-get update"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    galaxy_file   = "./requirements.yml"
    user          = "ubuntu"
    use_proxy     = false   
  }
}