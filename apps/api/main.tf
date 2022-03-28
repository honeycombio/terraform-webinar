terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.1"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.15.0"
    }
    honeycombio = {
      source  = "honeycombio/honeycombio"
      version = "~> 0.3.0"
    }
  }
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../../consul_hcp_eks/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.kubernetes_endpoint
  cluster_ca_certificate = data.terraform_remote_state.infra.outputs.kubernetes_certificate
  token                  = data.terraform_remote_state.infra.outputs.kubernetes_token
}

provider "consul" {
  address        = data.terraform_remote_state.infra.outputs.consul_url
  datacenter     = data.terraform_remote_state.infra.outputs.consul_datacenter
  ca_pem         = data.terraform_remote_state.infra.outputs.consul_ca
  token          = data.terraform_remote_state.infra.outputs.consul_root_token
  insecure_https = true
  scheme         = "https"
}

resource "kubernetes_service_account" "api" {
  metadata {
    name = "api"
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name = kubernetes_service_account.api.metadata[0].name
  }
  spec {
    selector = {
      app = "api"
    }

    port {
      port        = 9090
      protocol    = "TCP"
      target_port = 9090
    }
  }
}

resource "kubernetes_deployment" "api" {
  metadata {
    name = "api-deployment"
    labels = {
      app = "api_v1"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "api"
      }
    }

    template {
      metadata {
        labels = {
          app     = kubernetes_service.api.spec[0].selector.app
          metrics = "enabled"
        }

        annotations = {
          "honeycomb.io/metrics"                                          = "true"
          "honeycomb.io/scrape_port"                                      = "9102"
          "honeycomb.io/metrics_path"                                     = "/stats/prometheus"
          "consul.hashicorp.com/transparent-proxy-exclude-inbound-ports"  = "9102"
          "consul.hashicorp.com/transparent-proxy-exclude-outbound-ports" = "9411"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.api.metadata.0.name

        container {
          image = "nicholasjackson/fake-service:v0.23.1"
          name  = "api"

          port {
            container_port = 9090
            name           = "http"
          }

          env {
            name  = "NAME"
            value = "api"
          }

          env {
            name  = "LISTEN_ADDR"
            value = "0.0.0.0:9090"
          }

          env {
            name  = "TIMING_50_PERCENTILE"
            value = "20ms"
          }

          env {
            name  = "TIMING_90_PERCENTILE"
            value = "30ms"
          }

          env {
            name  = "TIMING_99_PERCENTILE"
            value = "40ms"
          }

          env {
            name  = "TRACING_ZIPKIN"
            value = "http://opentelemetry-collector.default.svc:9411"
          }

          env {
            name  = "READY_CHECK_RESPONSE_DELAY"
            value = "10s"
          }

          env {
            name  = "PORT"
            value = "9090"
          }

          env {
            name  = "UPSTREAM_URIS"
            value = "grpc://currency.default.svc:9090,http://cache.default.svc:9090,http://payments.default.svc:9090"
          }

          env {
            name  = "UPSTREAM_WORKERS"
            value = "2"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 9090
            }

            initial_delay_seconds = 5
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = 9090
            }

            initial_delay_seconds = 5
            period_seconds        = 5
          }

          resources {
            limits = {
              cpu    = "0.25"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}


resource "consul_config_entry" "api" {
  name = "api"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol = "http"
  })
}

resource "consul_intention" "api_web" {
  destination_name = "api"
  source_name      = "web"
  action           = "allow"
}