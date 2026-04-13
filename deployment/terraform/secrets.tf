data "aws_ssm_parameter" "secret_key_base" {
  name = "/cyber-dojo/web/secret_key_base"
}
