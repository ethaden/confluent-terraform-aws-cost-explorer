provider "aws" {
    region = var.aws_region

    default_tags {
      tags = try (module.confluent_terraform_aws_csta_base_module.confluent_tags, {})
    }
}
