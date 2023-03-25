
variable "name" {}
variable "repository" {}
variable "chart" {}
variable "extra_manifests" {
  default = []
}
variable "helm_version" {
  default = ""
}
variable "roles" {
  default = []
}
variable "service_account" {
  default =  false
}
variable "enable" {
  default = false
}
variable "project" {
default = ""
}
variable "username" {
  default = ""
}