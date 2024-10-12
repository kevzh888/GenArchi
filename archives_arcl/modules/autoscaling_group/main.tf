# Récupération de l'AMI Ubuntu la plus récente
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Création d'une clé privée RSA
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Création d'une paire de clés AWS
resource "aws_key_pair" "kp" {
  key_name   = var.private-key-name # Nom de la clé dans AWS
  public_key = tls_private_key.pk.public_key_openssh

  # Création locale du fichier de clé privée
  provisioner "local-exec" {
    command = <<EOF
      rm -f ./misc/shared_ssh.pem 2> /dev/null
      echo '${tls_private_key.pk.private_key_pem}' > ./misc/shared_ssh.pem
      chmod 400 ./misc/shared_ssh.pem
    EOF
  }
}

# Définition du modèle de lancement pour les instances EC2
resource "aws_launch_template" "template" {
  image_id               = "ami-09837f29678e3dbf0" # ID de l'AMI à utiliser
  instance_type          = "t2.micro" # Type d'instance EC2
  vpc_security_group_ids = [var.web-server-sg-id] # Groupe de sécurité associé
  description            = "Default free tier template"
  key_name               = aws_key_pair.kp.key_name # Nom de la paire de clés à utiliser
  /*user_data = base64encode(file("./misc/user_data.sh"))*/
}

# Création du groupe cible pour l'équilibreur de charge
resource "aws_lb_target_group" "frontend_target_group" {
  name        = "frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc-id
  target_type = "instance"
  health_check {
    port                = "traffic-port"
    path                = "/wordpress/wp-admin/install.php"
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  load_balancing_algorithm_type = "round_robin"
}

# Configuration du groupe d'autoscaling
resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = var.autoscaling-group-name
  desired_capacity     = 2 # Nombre souhaité d'instances
  max_size             = 2 # Nombre maximum d'instances
  min_size             = 2 # Nombre minimum d'instances
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"] # Politique de terminaison
  target_group_arns    = [aws_lb_target_group.frontend_target_group.arn] # Association au groupe cible
  vpc_zone_identifier  = var.subnet-id-list # Liste des sous-réseaux pour le déploiement

  launch_template {
    id      = aws_launch_template.template.id
    version = aws_launch_template.template.latest_version
  }
}