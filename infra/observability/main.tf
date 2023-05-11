resource "helm_release" "prometheus-stack" {
  name             = "prometheus"
  namespace        = "observability"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true

  values = [
    "${file("${path.module}/values.yaml")}"
  ]
}