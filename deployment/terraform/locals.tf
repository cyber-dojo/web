locals {
  app_env_vars = concat(
    [for key, value in var.app_env_vars : { name = key, value = value }],
    [{ name = "SECRET_KEY_BASE", value = var.SECRET_KEY_BASE }]
  )
}
