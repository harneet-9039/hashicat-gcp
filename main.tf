terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=3.68.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}



resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "hashicat" {
  name         = "${var.prefix}-hashicat"
  zone         = "${var.region}-b"
  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
   network = "default"
  }

  metadata = {
    ssh-keys = "ubuntu:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
  }

  tags = ["http-server"]

  labels = {
    name = "hashicat"
    department = "devops"
    billable = true
    
  }

}

resource "null_resource" "configure-cat-app" {
  depends_on = [
    google_compute_instance.hashicat,
  ]

  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "files/"
    destination = "/home/ubuntu/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      timeout     = "300s"
      private_key = tls_private_key.ssh-key.private_key_pem
      host        = google_compute_instance.hashicat.network_interface.0.access_config.0.nat_ip
    }
  }
}
