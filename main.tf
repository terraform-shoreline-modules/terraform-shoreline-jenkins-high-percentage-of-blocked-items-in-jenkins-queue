terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "high_percentage_of_blocked_items_in_jenkins_queue" {
  source    = "./modules/high_percentage_of_blocked_items_in_jenkins_queue"

  providers = {
    shoreline = shoreline
  }
}