variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "cluster_name" {
  type    = string
  default = "lab-eks"
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"
}