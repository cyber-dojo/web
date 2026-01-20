variable "service_name" {
  type    = string
  default = "web"
}

variable "env" {
  type = string
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "desired_count" {
  type    = number
  default = 3
}

variable "cpu_limit" {
  type    = number
  default = 100
}

variable "mem_limit" {
  type    = number
  default = 1024
}

variable "mem_reservation" {
  type    = number
  default = 128
}

variable "container_restart_policy_enabled" {
  description = "Whether to enable restart policy for the container."
  type        = bool
  default     = true
}

variable "TAGGED_IMAGE" {
  type = string
}

# App variables
variable "app_env_vars" {
  type = map(any)
  default = {
    CYBER_DOJO_PROMETHEUS      = "true"
    CYBER_DOJO_SAVER_PORT      = "4537"
    CYBER_DOJO_WEB_PORT        = "3000"
    CYBER_DOJO_RUNNER_PORT     = "4597"
    CYBER_DOJO_SAVER_HOSTNAME  = "saver.cyber-dojo.eu-central-1"
    CYBER_DOJO_RUNNER_HOSTNAME = "runner.cyber-dojo.eu-central-1"
    FORK_BUTTON                = ""
    DASHBOARD_BUTTON           = ""
    PREDICT                    = ""
    STARTING_INFO_DIALOG       = ""
  }
}

variable "ecr_replication_targets" {
  type    = list(map(string))
  default = []
}

variable "ecr_replication_origin" {
  type    = string
  default = ""
}
