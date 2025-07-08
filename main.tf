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

module "jemyeonso_iam" {
  source              = "./modules/iam"
}

module "jemyeonso_openvpn" {
  source             = "./modules/openvpn"

  stage              = var.stage
  servicename        = var.servicename
  tags               = var.openvpn_tags

  vpc_id             = module.jemyeonso_vpc.vpc_id
  vpc_security_group_ids = [module.jemyeonso_security_groups.sg_openvpn_id]
  subnet_id          = module.jemyeonso_vpc.public_az1_id

  depends_on = [ module.jemyeonso_vpc ]
}

module "jemyeonso_ec2" {
  source              = "./modules/instance"

  stage               = var.stage
  servicename         = var.servicename
  tags                = var.ec2_tags
  
  ami                 = var.ami
  instance_type       = var.instance_type
  ebs_volume          = var.instance_ebs_volume
  ebs_size            = var.instance_ebs_size

  vpc_id              = module.jemyeonso_vpc.vpc_id
  subnet_id           = module.jemyeonso_vpc.service_az1_id

  sg_ids              = [module.jemyeonso_security_groups.sg_ec2_id] 

  iam_instance_profile_name = module.jemyeonso_iam.ec2_instance_profile_name

  depends_on = [ module.jemyeonso_vpc ]
}


