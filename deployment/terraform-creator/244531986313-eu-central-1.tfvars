env = "staging"

# Allow to replicate app docker images to these accounts
ecr_replication_targets = [
  {
    "account_id" = "274425519734",
    "region"     = "eu-central-1"
  }
]

app_env_specific_vars = {
  CYBER_DOJO_ENV = "staging"
}
