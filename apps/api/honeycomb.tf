data "honeycombio_query_specification" "api_rq" {
  calculation {
    op     = "RATE_SUM"
    column = "envoy_http_downstream_rq_xx"
  }

  filter {
    column = "consul_source_service"
    op     = "="
    value  = "api"
  }

  breakdowns = ["envoy_response_code_class"]

  order {
    op     = "RATE_SUM"
    column = "envoy_http_downstream_rq_xx"
  }
}

resource "honeycombio_query" "api_rq" {
  dataset    = data.terraform_remote_state.infra.outputs.honeycomb_dataset_metrics
  query_json = data.honeycombio_query_specification.api_rq.json
}

resource "honeycombio_board" "api" {
  name = "API"

  query {
    dataset  = data.terraform_remote_state.infra.outputs.honeycomb_dataset_metrics
    query_id = honeycombio_query.api_rq.id
  }
}