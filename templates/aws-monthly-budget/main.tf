terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  ## TODO: option to move state to AWS S3
  # backend "aws" {}
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_budgets_budget" "all-monthly" {
  name         = "Monthly Budget (${var.project})"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  cost_filter {
    name = "TagKeyValue"
    values = [
      "user:project-is${"$"}${var.project}",
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.monthly_overspend_notify
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 125
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.monthly_overspend_notify
  }
}
