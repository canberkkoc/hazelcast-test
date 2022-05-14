resource "kubernetes_namespace" "namespaces" {
  for_each = toset(var.namespaces)
  metadata {
    annotations = {
      name = each.key
    }

    labels = {
      name = each.key
    }

    name = each.key
  }
}


resource "helm_release" "ingress" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  namespace  = "ingress"

  values = [
    file("values/ingress.yaml")
  ]
}


resource "helm_release" "vault" {
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  name       = "vault"
  namespace  = "vault"

  values = [
    file("values/vault.yaml")
  ]

  depends_on = [helm_release.ingress]
}

resource "helm_release" "prometheus_operator" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  name       = "prometheus-operator"
  namespace  = "prometheus"

  values = [
    file("values/prometheus-operator.yaml")
  ]

  set {
    name  = "alertmanager.alertmanagerSpec.externalUrl"
    value = "http://${var.domain}/alertmanager"
  }

  set {
    name  = "prometheus.prometheusSpec.externalUrl"
    value = "http://${var.domain}/prometheus"
  }



  depends_on = [helm_release.vault]
}


