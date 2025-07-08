module "jemyeonso_vpc" {
  source              = "./modules/vpc"

  stage               = var.stage
  servicename         = var.servicename
  tags                = var.vpc_tags

  az                  = var.az
  vpc_ip_range        = var.vpc_ip_range

  subnet_public_az1   = var.subnet_public_az1
  subnet_public_az2   = var.subnet_public_az2
  subnet_service_az1  = var.subnet_service_az1
  subnet_service_az2  = var.subnet_service_az2
  subnet_db_az1       = var.subnet_db_az1
  subnet_db_az2       = var.subnet_db_az2
}

module "jemyeonso_security_groups" {
  source              = "./modules/security_group"

  stage               = var.stage
  servicename         = var.servicename

  vpc_id              = module.jemyeonso_vpc.vpc_id
}