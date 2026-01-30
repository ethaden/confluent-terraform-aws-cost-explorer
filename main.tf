# The following module is just empty and only used for making Terraform happy.
# Copy override.tf-template override.tf if you want to actually use it
module "confluent_terraform_aws_csta_base_module" {
    source = "./empty_module"
}

locals {
    extra_tags = try (module.confluent_terraform_aws_csta_base_module.extra_tags, {})
    resource_prefix = var.resource_prefix!="" ? var.resource_prefix : try (module.confluent_terraform_aws_csta_base_module.username, "")
}

resource "aws_budgets_budget" "budget" {
  name              = "${local.resource_prefix}-budget"
  budget_type       = "COST"
  limit_amount      = var.cost_limit
  limit_unit        = "USD"
  time_period_start = "2026-01-01_00:00"
  time_period_end   = "2086-12-31_00:00"
  time_unit         = "MONTHLY"

  cost_filter {
    name = "TagKeyValue"
    values = [
      "cflt_managed_id${"$"}${var.owner}"
    ]
  }

  # For testing!
#  notification {
#    comparison_operator        = "GREATER_THAN"
#    threshold                  = 10
#    threshold_type             = "PERCENTAGE"
#    notification_type          = "FORECASTED"
#    subscriber_email_addresses = [var.owner_email]
#  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.owner_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.owner_email]
  }
}
