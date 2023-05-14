variable "zone_id" {
  type    = string
}

variable "domain" {
  type = string
}

variable "aliases" {
  type    = list(string)
  default = []
}

variable "s3_bucket" {
  type = string
}

variable "content_security_policy" {
  type    = string
  default = "default-src 'self'; style-src 'self' 'unsafe-inline'; object-src 'none'; frame-ancestors 'none'; base-uri 'none'"
}
