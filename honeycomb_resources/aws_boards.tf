resource "honeycombio_query" "cloudwatch_ec2_cpu" {
  dataset    = local.datasets.cloudwatch-metrics
  query_json = data.honeycombio_query_specification.cloudwatch_ec2_cpu.json
}

resource "honeycombio_query_annotation" "cloudwatch_ec2_cpu" {
  dataset  = local.datasets.cloudwatch-metrics
  query_id = honeycombio_query.cloudwatch_ec2_cpu.id

  name        = "EC2 CPU"
  description = "EC2 CPU Utilization by Instance"
}

resource "honeycombio_query" "cloudwatch_ec2_network" {
  dataset    = local.datasets.cloudwatch-metrics
  query_json = data.honeycombio_query_specification.cloudwatch_ec2_network.json
}

resource "honeycombio_query_annotation" "cloudwatch_ec2_network" {
  dataset  = local.datasets.cloudwatch-metrics
  query_id = honeycombio_query.cloudwatch_ec2_network.id

  name        = "EC2 Networking"
  description = "EC2 Network In/Out by Instance"
}

resource "honeycombio_board" "cloudwatch_ec2" {
  name  = "CloudWatch EC2 Metrics"
  style = "visual"

  query {
    dataset             = local.datasets.cloudwatch-metrics
    query_id            = honeycombio_query.cloudwatch_ec2_cpu.id
    query_annotation_id = honeycombio_query_annotation.cloudwatch_ec2_cpu.id
  }

  query {
    dataset             = local.datasets.cloudwatch-metrics
    query_id            = honeycombio_query.cloudwatch_ec2_network.id
    query_annotation_id = honeycombio_query_annotation.cloudwatch_ec2_network.id
  }
}
