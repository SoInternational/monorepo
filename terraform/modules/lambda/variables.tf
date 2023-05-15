variable "name" {
  type = string
}

variable "source_dir" {
  type = string
}

variable "handler" {
  type    = string
  default = "main.handler"
}

variable "runtime" {
  type    = string
  default = "nodejs14.x"
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "apigateway_execution_arns" {
  type    = list(string)
  default = []
}

variable "policy_statements" {
  type = map(object({
    effect    = optional(string)
    actions   = list(string)
    resources = list(string)
  }))
  default = {}
}
