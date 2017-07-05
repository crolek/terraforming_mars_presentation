module "site" {
  source                = "./modules/00site"

  availability_zone     = "${var.availability_zone}"
  env                   = "${var.env}"
  vpc_cidr              = "${var.vpc_cidr}"
}

module "application" {
  source                    = "./modules/10applications"

  ami                       = "${var.ami}"
  application_subnet_0_id   = "${module.site.application_subnet_0_id}"
  availability_zone         = "${var.availability_zone}"
  env                       = "${var.env}"
  key_name                  = "${var.key_name}"
  vpc_id                    = "${module.site.vpc_id}"
}


provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
}

# Remote backend hack :(
terraform {
  backend "s3" {
    bucket  = "terraforming-mars-state"
    key     = "terraforming-mars-dev.tfstate"
    region  = "us-east-1"
    profile = "personal"
  }
}