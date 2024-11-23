variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "process_email_lambda" {
  type = object({
    dist_dir = string
    handler  = string
    name     = string
  })
}

variable "process_llm_output_lambda" {
  type = object({
    dist_dir = string
    handler  = string
    name     = string
  })
}

variable "bucket_events_rule" {
  type = object({
    name = string
    arn  = string
  })
}

variable "bucket" {
  type = object({
    id  = string
    arn = string
  })
}

variable "newsletter_feeds_table" {
  type = object({
    name = string
    arn  = string
  })
}

variable "feed_config_table" {
  type = object({
    name             = string
    arn              = string
    sender_email_gsi = string
  })
}

variable "shorted_links_table" {
  type = object({
    name = string
    arn  = string
  })
}

