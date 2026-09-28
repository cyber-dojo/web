variable "service_name" {
  type    = string
  default = "creator"
}

variable "env" {
  type = string
}

variable "app_port" {
  type    = number
  default = 4523
}

variable "cpu_limit" {
  type    = number
  default = 256
}

variable "mem_limit" {
  type    = number
  default = 512
}

variable "mem_reservation" {
  type    = number
  default = 32
}

variable "TAGGED_IMAGE" {
  type = string
}

variable "container_restart_policy_enabled" {
  description = "Whether to enable restart policy for the container."
  type        = bool
  default     = true
}

# App variables
variable "app_env_vars" {
  type = map(any)
  default = {
    CYBER_DOJO_CUSTOM_START_POINTS_PORT        = "4526"
    CYBER_DOJO_EXERCISES_START_POINTS_PORT     = "4525"
    CYBER_DOJO_LANGUAGES_START_POINTS_PORT     = "4524"
    CYBER_DOJO_CREATOR_PORT                    = "4523"
    CYBER_DOJO_RUNNER_PORT                     = "4597"
    CYBER_DOJO_SAVER_PORT                      = "4537"
    CYBER_DOJO_CUSTOM_START_POINTS_HOSTNAME    = "custom-start-points.cyber-dojo.eu-central-1"
    CYBER_DOJO_EXERCISES_START_POINTS_HOSTNAME = "exercises-start-points.cyber-dojo.eu-central-1"
    CYBER_DOJO_LANGUAGES_START_POINTS_HOSTNAME = "languages-start-points.cyber-dojo.eu-central-1"
    CYBER_DOJO_RUNNER_HOSTNAME                 = "runner.cyber-dojo.eu-central-1"
    CYBER_DOJO_SAVER_HOSTNAME                  = "saver.cyber-dojo.eu-central-1"
  }
}

variable "app_env_specific_vars" {
  type    = map(any)
  default = {}
}

variable "ecr_replication_targets" {
  type    = list(map(string))
  default = []
}

variable "ecr_replication_origin" {
  type    = string
  default = ""
}
