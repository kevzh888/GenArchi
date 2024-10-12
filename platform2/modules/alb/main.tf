# Création d'un nouveau équilibreur de charge (Application Load Balancer)
resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"  # Nom de l'équilibreur de charge
  internal           = false           # Équilibreur de charge externe (accessible depuis Internet)
  load_balancer_type = "application"   # Type d'équilibreur de charge : Application Load Balancer
  security_groups    = [var.security-group]  # Groupe de sécurité associé à l'ALB
  subnets            = var.subnet-id-list    # Liste des sous-réseaux où l'ALB sera déployé

  enable_deletion_protection = false    # Désactivation de la protection contre la suppression
}

# Création d'un écouteur HTTP pour l'équilibreur de charge
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn  # ARN de l'équilibreur de charge associé
  port              = 80                       # Port d'écoute (HTTP)
  protocol          = "HTTP"                   # Protocole utilisé
  default_action {
    type             = "forward"               # Action par défaut : transférer le trafic
    target_group_arn = var.target-group-arn    # ARN du groupe cible pour le transfert
  }
}