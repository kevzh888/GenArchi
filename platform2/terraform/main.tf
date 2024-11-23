# --- Architecture ---
# VPC, sous-réseaux et routeurs : Un VPC avec des sous-réseaux publics et privés, et un Internet Gateway pour permettre l'accès Internet aux instances situées dans le sous-réseau public.
# Groupes de sécurité : Des groupes de sécurité permettent de contrôler les flux réseau entre les différents tiers (web, app, et base de données).
# Load Balancer (ELB) : Un ELB répartit la charge sur les instances du tiers Web (Auto Scaling Group Web).
# Auto Scaling Groups : Deux groupes ASG sont définis pour les tiers Web et App, permettant une mise à l'échelle automatique des instances selon la charge.
# Instance de base de données : Une instance EC2 héberge MySQL, servant de base de données dans le sous-réseau privé.

# --- VPC ---
module "vpc" {
  source = "./modules/vpc"
}

# --- Internet Gateway ---
module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
}

# --- Subnets ---
module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  igw_id = module.internet_gateway.igw_id
}

# --- Security Groups ---
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# --- Load Balancer for Web Tier ---
module "web_lb" {
  source           = "./modules/web_lb"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id_1 = module.subnets.public_subnet_id_1
  public_subnet_id_2 = module.subnets.public_subnet_id_2
  web_sg_id        = module.security_groups.web_sg_id
}

module "web_asg" {
  source           = "./modules/web_asg"
  public_subnet_id_1 = module.subnets.public_subnet_id_1
  public_subnet_id_2 = module.subnets.public_subnet_id_2
  web_sg_id        = module.security_groups.web_sg_id
  target_group_arn = module.web_lb.web_target_group_arn
  app_lb_dns = module.app_lb.dns_name
}

# --- Load Balancer for App Tier ---
module "app_lb" {
  source           = "./modules/app_lb"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id_1 = module.subnets.public_subnet_id_1
  public_subnet_id_2 = module.subnets.public_subnet_id_2
  app_sg_id        = module.security_groups.app_sg_id
}

module "app_asg" {
  source            = "./modules/app_asg"
  /*private_subnet_id_1 = module.subnets.private_subnet_id_1
  private_subnet_id_2 = module.subnets.private_subnet_id_2*/

  target_group_arn = module.app_lb.target_group_arn

  public_subnet_id_1 = module.subnets.public_subnet_id_1
  public_subnet_id_2 = module.subnets.public_subnet_id_2
  app_sg_id         = module.security_groups.app_sg_id
  db_ip_1           = ""
  db_ip_2           = ""
}

# --- Database EC2 Instance ---

module "database_eip" {
  source = "./modules/database_eip"
}

module "database_nlb" {
  source = "./modules/database_nlb"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id_1 = module.subnets.public_subnet_id_1
  public_subnet_id_2 = module.subnets.public_subnet_id_2
  db_sg_id        = module.security_groups.db_sg_id
}

module "database_asg" {
  source = "./modules/database_asg"
  public_subnet_id_1 = module.subnets.public_subnet_id_1
  public_subnet_id_2 = module.subnets.public_subnet_id_2
  target_group_arn = module.database_nlb.db_target_group_arn
  master_eip_id = module.database_eip.master_eip_id
  master_eip_public_ip = module.database_eip.master_eip_public_ip
  db_sg_id = module.security_groups.db_sg_id
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}

/*module "database_ec2" {
  source            = "./modules/database_ec2"
  public_subnet_id  = module.subnets.public_subnet_id_1
  db_sg_id          = module.security_groups.db_sg_id
}

module "database_ec2_slave" {
  source            = "./modules/database_ec2_slave"
  public_subnet_id  = module.subnets.public_subnet_id_2
  db_sg_id          = module.security_groups.db_sg_id
  master_public_ip = module.database_ec2.db_instance_public_ip
}*/

/*module "static_site" {
  source = "./modules/s3_static_site"
}*/
