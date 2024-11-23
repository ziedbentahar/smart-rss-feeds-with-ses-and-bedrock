module "subdomain_setup" {
  source = "./modules/subdomain-setup"

  domain    = var.domain
  subdomain = var.subdomain
}


module "email_handling" {
  source = "./modules/email-handling"

  application = var.application
  environment = var.environment
  domain      = var.domain
  subdomain   = var.subdomain

  subdomain_zone = module.subdomain_setup.subdomain_zone
}


module "stores" {
  source = "./modules/stores"

  application = var.application
  environment = var.environment

}

module "feed_generation" {
  source = "./modules/feed-generation"

  application = var.application
  environment = var.environment

  process_email_lambda = {
    dist_dir = "../src/dist/email-handling/lambda-handlers"
    name     = "process-email"
    handler  = "process-email.handler"
  }

  process_llm_output_lambda = {
    dist_dir = "../src/dist/email-handling"
    name     = "process-llm-output"
    handler  = "process-llm-output.handler"
  }

  bucket = module.email_handling.bucket

  newsletter_feeds_table = module.stores.newsletter_feeds_table
  feed_config_table      = module.stores.feed_config_table
  shorted_links_table    = module.stores.shorted_links_table
}

module "api" {
  source = "./modules/api"

  application = var.application
  environment = var.environment


  api_lambda = {
    dist_dir = "../src/dist/api"
    name     = "api"
    handler  = "index.handler"
  }

  newsletter_feeds_table = module.stores.newsletter_feeds_table
  shorted_links_table    = module.stores.shorted_links_table

  domain    = var.domain
  subdomain = var.subdomain

  subdomain_zone = module.subdomain_setup.subdomain_zone

  emails_bucket = module.email_handling.bucket

}
