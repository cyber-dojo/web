terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.1"
    }
  }
}
