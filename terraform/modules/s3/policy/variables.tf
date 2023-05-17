variable "bucket" {
  type = string
}

variable "cloudfront_ids" {
  type    = list(string)
  default = []
}
