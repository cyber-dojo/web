terraform {
  backend "s3" {
    bucket         = "terraform-state-9d7e951c290ec5bbe6506e0ddb064808764bc636"
    key            = "terraform/creator/gh_environments/main.tfstate"
    dynamodb_table = "terraform-state-9d7e951c290ec5bbe6506e0ddb064808764bc636"
    encrypt        = true
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.28.0"
    }
  }
}

# See auth details here https://registry.terraform.io/providers/integrations/github/latest/docs
provider "github" {
  owner = "cyber-dojo"
}

data "github_team" "production_deploy" {
  slug = "production_deploy"
}

resource "github_repository_environment" "staging" {
  environment = "staging"
  repository  = var.repository_name
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment" "production" {
  environment = "production"
  repository  = var.repository_name
  reviewers {
    teams = [data.github_team.production_deploy.id]
  }
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}
