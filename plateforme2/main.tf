module "default_vpc" {
  source = "./modules/vpc"
}

module "subnets" {
  source         = "./modules/subnet"
  vpc-id         = module.default_vpc.vpc-id
  route-table-id = module.default_vpc.route-table-id
}

module "web_server_sg" {
  source = "./modules/webserver_security_group"
  vpc-id = module.default_vpc.vpc-id
}

module "autoscaling_group" {
  source           = "./modules/autoscaling_group"
  web-server-sg-id = module.web_server_sg.sg_id
  vpc-id           = module.default_vpc.vpc-id
  subnet-id-list   = [module.subnets.subnet1_id, module.subnets.subnet2_id, module.subnets.subnet3_id]
}
module "frontend_alb" {
  source           = "./modules/alb"
  security-group   = module.web_server_sg.sg_id
  subnet-id-list   = [module.subnets.subnet1_id, module.subnets.subnet2_id, module.subnets.subnet3_id]
  target-group-arn = module.autoscaling_group.asg-target-group-arn
}