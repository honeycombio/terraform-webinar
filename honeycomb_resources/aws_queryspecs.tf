data "honeycombio_query_specification" "cloudwatch_ec2_cpu" {
  time_range  = 28800
  granularity = var.cloudwatch_granularity

  breakdowns = ["InstanceId"]

  calculation {
    op     = "MAX"
    column = "amazonaws.com/AWS/EC2/CPUUtilization.max"
  }

  filter {
    column = "InstanceId"
    op     = "exists"
  }

  order {
    column = "InstanceId"
    order  = "ascending"
  }
}

data "honeycombio_query_specification" "cloudwatch_ec2_network" {
  time_range  = 28800
  granularity = var.cloudwatch_granularity

  breakdowns = ["InstanceId"]

  calculation {
    op     = "MAX"
    column = "amazonaws.com/AWS/EC2/NetworkIn.max"
  }

  calculation {
    op     = "MAX"
    column = "amazonaws.com/AWS/EC2/NetworkOut.max"
  }

  calculation {
    op     = "MAX"
    column = "amazonaws.com/AWS/EC2/NetworkPacketsIn.max"
  }

  calculation {
    op     = "MAX"
    column = "amazonaws.com/AWS/EC2/NetworkPacketsOut.max"
  }

  filter {
    column = "InstanceId"
    op     = "exists"
  }

  order {
    column = "InstanceId"
    order  = "ascending"
  }
}
