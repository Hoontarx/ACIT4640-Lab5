# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "debian" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "debian-*-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"]
  }
  ssh_username = "admin"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    "source.amazon-ebs.debian",
  ]

  provisioner "shell" {
    inline = [
      "echo creating directories",
      "sudo mkdir -p /web/html",
      "sudo mkdir -p /tmp/web",
      "sudo chown -R admin:admin /web/html",
      "sudo chown -R admin:admin /tmp/web",
      "sudo chmod -R 755 /web/html"
    ]
  }

  provisioner "file" {
    source      = "files/index.html"
    destination = "/web/html/index.html"
  }

  provisioner "file" {
    source      = "files/nginx.conf"
    destination = "/tmp/web/nginx.conf"
  }

  provisioner "file" {
    source      = "scripts/install-nginx"
    destination = "/tmp/install-nginx"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install-nginx",
      "sudo /tmp/install-nginx"
    ]
  }

  provisioner "file" {
    source      = "scripts/setup-nginx"
    destination = "/tmp/setup-nginx"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup-nginx",
      "sudo /tmp/setup-nginx"
    ]
  }
}