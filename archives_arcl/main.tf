# Module pour créer le VPC (Virtual Private Cloud)
module "vpc" {
  source = "./modules/vpc"
}

# Module pour créer les sous-réseaux
module "subnets" {
  source         = "./modules/subnet"
  vpc-id         = module.vpc.vpc-id
  route-table-id = module.vpc.route-table-id
}

# Module pour créer le groupe de sécurité
module "security_group_module" {
  source = "./modules/security_group"
  vpc-id = module.vpc.vpc-id
}

# Module pour créer le groupe d'autoscaling
module "autoscaling_group" {
  source           = "./modules/autoscaling_group"
  web-server-sg-id = module.security_group_module.sg_id
  vpc-id           = module.vpc.vpc-id
  subnet-id-list   = [module.subnets.subnet1_id, module.subnets.subnet2_id, module.subnets.subnet3_id]
}

# Module pour créer l'équilibreur de charge d'application frontend
module "frontend_alb" {
  source           = "./modules/alb"
  security-group   = module.security_group_module.sg_id
  subnet-id-list   = [module.subnets.subnet1_id, module.subnets.subnet2_id, module.subnets.subnet3_id]
  target-group-arn = module.autoscaling_group.asg-target-group-arn
}