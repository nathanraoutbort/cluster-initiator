
resource "helm_release" "helm" {
  name       = var.name
  create_namespace = true
  namespace = var.name
  repository = var.repository
  chart      = var.chart
  version    = try(var.helm_version,"")
  values = [
    "${fileexists("../helm-charts/${var.name}/${var.name}.yml") ? templatefile("../helm-charts/${var.name}/${var.name}.yml", {project = var.project, username = var.username}) : ""}"
  ]
}

resource "kubectl_manifest" "kubectl_apply" {
    for_each = toset(var.extra_manifests)
    yaml_body = file("../helm-charts/${var.name}/extra-manifests/${each.value}")
    depends_on = [
      helm_release.helm
    ]
}

resource "google_service_account" "service_account" {
  count = var.service_account ? 1 : 0
  account_id   = "${var.name}-${var.username}"
  description  = "Service Account Created by Terraform"
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  count = var.service_account ? 1 : 0
  service_account_id = google_service_account.service_account[count.index].name
  role = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project}.svc.id.goog[${var.name}/${var.name}]"
  ]
}

resource "google_project_iam_binding" "roles" {
  for_each = toset(var.roles)
  project =  var.project
  role = each.key
  members = [
    "serviceAccount:${google_service_account.service_account[0].email}"
  ]
}
