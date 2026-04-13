locals {
  app_env_vars = [
    for key, value in merge(var.app_env_vars, { SECRET_KEY_BASE = data.aws_ssm_parameter.secret_key_base.value }) : {
      name  = key
      value = value
    }
  ]
}
