terraform {
  backend "s3" {}
}

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}

module "tags" {
  source            = "fivexl/tag-generator/aws"
  version           = "2.0.0"
  prefix            = "cyber-dojo"
  terraform_managed = "1"
  environment_name  = var.env
  data_owner        = "cyber-dojo"
  data_pci          = "0"
  data_phi          = "0"
  data_pii          = "0"
}