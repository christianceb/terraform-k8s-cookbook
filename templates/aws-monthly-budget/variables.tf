variable "profile" {
  description = "The aws-cli profile name to use for this operation"
}

variable "project" {
  description = "Give your project a name. Kebab-case names only"
}

variable "region" {
  description = "The target region for the operations. Any operation requiring a specific availability zone will default to \"a\""
  default = "us-east-2"
}

variable "monthly_budget_usd" {
  description = "How much are you willing to spend in USD every month?"
}

variable "monthly_overspend_notify" {
  type = list(string)
  description = "List of email addresses to notify once monthly spend has hit 100% and 125% of the budget"
}
