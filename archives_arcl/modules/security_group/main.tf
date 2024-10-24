# Définition du groupe de sécurité AWS
resource "aws_security_group" "security_group_module" {
  # Nom du groupe de sécurité, défini par une variable
  name        = var.security-group-name
  # Description du groupe de sécurité, définie par une variable
  description = var.security-group-description
  # ID du VPC associé au groupe de sécurité, défini par une variable
  vpc_id      = var.vpc-id

  # Règle d'entrée pour autoriser le trafic HTTP depuis n'importe où
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle d'entrée pour autoriser le trafic ICMP depuis n'importe où
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle d'entrée pour autoriser le trafic SSH depuis n'importe où
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle de sortie pour autoriser tout le trafic sortant par défaut
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
