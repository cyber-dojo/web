locals {
  app_env_vars = concat([
    for key, value in var.app_env_vars :
    {
      name  = key
      value = value
    }
    ],
    [
      for key, value in var.app_env_specific_vars :
      {
        name  = key
        value = value
      }
    ]
  )
}
