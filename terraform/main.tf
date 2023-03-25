
resource "google_container_cluster" "primary" {
  name               = "${var.username}-cluster"
  location           = "europe-west1-b"
  initial_node_count = 3
  node_config {
    disk_size_gb = 10
    machine_type = "e2-medium"
  }
  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }
}

module "ingress-nginx" {
  source     = "./modules/helm-chart-modules/"
  enable     = true
  project    = var.project
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  depends_on = [
    google_container_cluster.primary
  ]
}

module "external-dns" {
  source          = "./modules/helm-chart-modules/"
  enable          = true
  project         = var.project
  name            = "external-dns"
  repository      = "https://kubernetes-sigs.github.io/external-dns/"
  chart           = "external-dns"
  helm_version    = "1.12.1"
  service_account = true
  username =  var.username
  roles           = ["roles/dns.admin"]
  depends_on = [
    module.ingress-nginx
  ]
}

module "cert-manager" {
  source          = "./modules/helm-chart-modules/"
  enable          = true
  project         = var.project
  name            = "cert-manager"
  repository      = "https://charts.jetstack.io"
  chart           = "cert-manager"
  extra_manifests = ["issuer.yml"]
  depends_on = [
    module.external-dns
  ]
}

module "nginx" {
  source          = "./modules/helm-chart-modules/"
  enable          = true
  project         = var.project
  name            = "nginx"
  repository      = "../helm-charts"
  chart           = "nginx"
  username =  var.username
  depends_on = [
    module.cert-manager
  ]
}