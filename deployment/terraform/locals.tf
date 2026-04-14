locals {
  app_env_vars = [
    for key, value in var.app_env_vars : {
      name  = key
      value = value
    }
  ]
}
