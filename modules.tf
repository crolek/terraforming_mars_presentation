module "site" {
  source                = "./modules/00site"

  ami                   = "${var.ami}"
  availability_zone_0   = "${var.availability_zone_0}"
  availability_zone_1   = "${var.availability_zone_1}"
  env                   = "${var.env}"
  key_name              = "${var.key_name}"
  vpc_cidr              = "${var.vpc_cidr}"
}

module "application" {
  source                    = "./modules/10applications"

  ami                       = "${var.ami}"
  application_subnet_0_id   = "${module.site.application_subnet_0_id}"
  availability_zone_0       = "${var.availability_zone_0}"
  env                       = "${var.env}"
  key_name                  = "${var.key_name}"
  vpc_id                    = "${module.site.vpc_id}"
}

module "beanstalk" {
  source                    = "./modules/99beanstalk"

  ami                       = "${var.ami}"
  application_subnet_0_id   = "${module.site.application_subnet_0_id}"
  availability_zone_0       = "${var.availability_zone_0}"
  availability_zone_1       = "${var.availability_zone_1}"
  env                       = "${var.env}"
  key_name                  = "${var.key_name}"
  vpc_id                    = "${module.site.vpc_id}"
  public_route_table_id     = "${module.site.public_route_table_id}"
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