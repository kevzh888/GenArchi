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

# --- Subnets ---
module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
}

# --- Security Groups ---
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# --- Load Balancer for Web Tier ---
module "web_lb" {
  source = "./modules/web_lb"
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.subnets.public_subnet_id
  web_sg_id = module.security_groups.web_sg_id
}

module "web_asg" {
  source = "./modules/web_asg"
  public_subnet_id = module.subnets.public_subnet_id
  web_sg_id = module.security_groups.web_sg_id
}

module "app_asg" {
  source            = "./modules/app_asg"
  private_subnet_id = module.subnets.private_subnet_id
  app_sg_id         = module.security_groups.app_sg_id
}

# --- Database EC2 Instance ---
module "database_ec2" {
  source = "./modules/database_ec2"
  private_subnet_id = module.subnets.private_subnet_id
  db_sg_id = module.security_groups.db_sg_id
}
