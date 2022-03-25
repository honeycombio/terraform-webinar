terraform {
  required_version = ">= 1.0.0"

  required_providers {
    honeycombio = {
      source  = "honeycombio/honeycombio"
      version = "~> 0.3"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 1.4"
    }
  }
}

provider "honeycombio" {
  # set API key with env var HONEYCOMBIO_APIKEY
}
