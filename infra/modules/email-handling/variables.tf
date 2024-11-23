variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "subdomain_zone" {
  type = object({
    id   = string
    name = string
  })
}

variable "bucket" {
  type = object({
    id  = string
    arn = string
  })
}
