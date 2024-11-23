variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "api_lambda" {
  type = object({
    dist_dir = string
    handler  = string
    name     = string
  })
}


variable "domain" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "newsletter_feeds_table" {
  type = object({
    name = string
    arn  = string
  })
}

variable "shorted_links_table" {
  type = object({
    name = string
    arn  = string
  })
}

variable "subdomain_zone" {
  type = object({
    id   = string
    name = string
  })
}

variable "emails_bucket" {
  type = object({
    id  = string
    arn = string
  })
}
