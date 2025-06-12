

resource "kubernetes_manifest" "letsencrypt_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name      = "letsencrypt"
    }
    spec = {
      acme = {
        email   = var.cert-email
        server  = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-tls-secret"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "app_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "app-cert"
      namespace = "default"
    }
    spec = {
      secretName = "app-tls"
      dnsNames  = ["app.danielfarag.cloud"]
      issuerRef = {
        name = "letsencrypt"
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [ kubernetes_manifest.letsencrypt_issuer ]
}

resource "kubernetes_manifest" "argocd_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "argocd-cert"
      namespace = "default"
    }
    spec = {
      secretName = "argocd-tls"
      dnsNames  = ["argocd.danielfarag.cloud"]
      issuerRef = {
        name = "letsencrypt"
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [ kubernetes_manifest.letsencrypt_issuer ]
}

resource "kubernetes_manifest" "jenkins_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "jenkins-cert"
      namespace = "default"
    }
    spec = {
      secretName = "jenkins-tls"
      dnsNames  = ["jenkins.danielfarag.cloud"]
      issuerRef = {
        name = "letsencrypt"
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [ kubernetes_manifest.letsencrypt_issuer ]
}

resource "kubernetes_manifest" "prometheus_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "prometheus-cert"
      namespace = "default"
    }
    spec = {
      secretName = "prometheus-tls"
      dnsNames  = ["prometheus.danielfarag.cloud"]
      issuerRef = {
        name = "letsencrypt"
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [ kubernetes_manifest.letsencrypt_issuer ]
}

resource "kubernetes_manifest" "grafana_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "grafana-cert"
      namespace = "default"
    }
    spec = {
      secretName = "grafana-tls"
      dnsNames  = ["grafana.danielfarag.cloud"]
      issuerRef = {
        name = "letsencrypt"
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [ kubernetes_manifest.letsencrypt_issuer ]
}

resource "kubernetes_manifest" "alertmanager_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "alertmanager-cert"
      namespace = "default"
    }
    spec = {
      secretName = "alertmanager-tls"
      dnsNames  = ["alertmanager.danielfarag.cloud"]
      issuerRef = {
        name = "letsencrypt"
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [ kubernetes_manifest.letsencrypt_issuer ]
}
