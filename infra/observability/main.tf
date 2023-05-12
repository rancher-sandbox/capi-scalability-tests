terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

resource "kubectl_manifest" "namespace" {
    yaml_body = file("${path.module}/namespace.yaml")
}

resource "kubectl_manifest" "ksmetrics" {
    yaml_body = file("${path.module}/cr-state-metrics.yaml")
}

resource "helm_release" "prometheus-stack" {
  name             = "prometheus"
  namespace        = "observability"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = false

  values = [
    "${file("${path.module}/values.yaml")}"
  ]

  depends_on = [ 
    kubectl_manifest.namespace,
    kubectl_manifest.ksmetrics
  ]
}