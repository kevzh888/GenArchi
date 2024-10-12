# Création d'un nouveau équilibreur de charge (ELB)
resource "aws_elb" "frontend_elb" {
  # Nom de l'équilibreur de charge
  name               = "frontend-elb"
  # Zones de disponibilité dans lesquelles l'ELB sera déployé
  availability_zones = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]

  # Configuration de l'écouteur (listener) pour le trafic entrant
  listener {
    instance_port     = 80    # Port sur lequel les instances EC2 écoutent
    instance_protocol = "http" # Protocole utilisé par les instances
    lb_port           = 80    # Port sur lequel l'ELB écoute
    lb_protocol       = "http" # Protocole utilisé par l'ELB
  }

  # Configuration de la vérification de l'état de santé des instances
  health_check {
    healthy_threshold   = 2      # Nombre de vérifications réussies avant de déclarer une instance saine
    unhealthy_threshold = 2      # Nombre de vérifications échouées avant de déclarer une instance malsaine
    timeout             = 3      # Délai d'attente pour chaque vérification de santé
    target              = "HTTP:8000/" # Cible de la vérification de santé (protocole, port et chemin)
    interval            = 30     # Intervalle entre les vérifications de santé
  }

  # Activation de l'équilibrage de charge entre les zones
  cross_zone_load_balancing   = true
  # Délai d'inactivité avant de fermer une connexion inactive
  idle_timeout                = 400
  # Activation de la vidange des connexions lors de la désinscription d'une instance
  connection_draining         = true
  # Délai maximum pour la vidange des connexions
  connection_draining_timeout = 400

  # Étiquettes pour identifier l'ELB
  tags = {
    Name = "frontend-elb"
  }
}