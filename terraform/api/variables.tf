variable "name" {
  type    = string
  default = ""
}

variable "zone_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "protocol_type" {
  type    = string
  default = "HTTP"
}

variable "cors" {
  type = object({
    allow_headers = list(string)
    allow_methods = list(string)
    allow_origins = list(string)
  })
  default = null
}

variable "integrations" {
  type    = map(any)
  default = null
}
