
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = "europe-west1-b"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "google_client_config" "default" {
  depends_on = [
    google_container_cluster.primary
  ]
}

data "google_container_cluster" "my_cluster" {
  name     = "${var.username}-cluster"
  location = "europe-west1-b"
  depends_on = [
    google_container_cluster.primary
  ]
}

provider "kubectl" {
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
  load_config_file       = false

}