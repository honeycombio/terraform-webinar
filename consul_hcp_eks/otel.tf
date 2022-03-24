resource "helm_release" "otel" {
  name            = "opentelemetry-collector"
  chart           = "opentelemetry-collector"
  repository      = "https://honeycombio.github.io/helm-charts"
  cleanup_on_fail = true

  dynamic "set" {
    for_each = {
      "honeycomb.apiKey" = var.honeycomb_api_key

    }

    content {
      name  = set.key
      value = set.value
    }
  }

  values = [
    "${file("otel_values.yaml")}"
  ]
}

# Confgiure Consul to use the Honeycomb collector
resource "consul_config_entry" "proxy_defaults" {
  kind = "proxy-defaults"
  # Note that only "global" is currently supported for proxy-defaults and that
  # Consul will override this attribute if you set it to anything else.
  name = "global"

  config_json = jsonencode({
    Config = {
      envoy_stats_bind_addr = "0.0.0.0:9102"
      envoy_tracing_json    = <<EOF
{
  "http": {
    "name": "envoy.tracers.zipkin",
    "typedConfig": {
      "@type": "type.googleapis.com/envoy.config.trace.v3.ZipkinConfig",
      "collector_cluster": "zipkin",
      "collector_endpoint_version": "HTTP_JSON",
      "collector_endpoint": "/api/v2/spans",
      "shared_span_context": false
    }
  }
}
EOF

      envoy_extra_static_clusters_json = <<EOF
{
  "connect_timeout":"3.000s",
  "dns_lookup_family":"V4_ONLY",
  "lb_policy":"ROUND_ROBIN",
  "load_assignment":{
    "cluster_name":"zipkin",
    "endpoints":[
      {
        "lb_endpoints":[
          {
            "endpoint":{
              "address":{
                "socket_address":{
                  "address":"opentelemetry-collector.default.svc",
                  "port_value":9411,
                  "protocol":"TCP"
                }
              }
            }
          }
        ]
      }
    ]
  },
  "name":"zipkin",
  "type":"STRICT_DNS"
}
EOF
    }
  })
}