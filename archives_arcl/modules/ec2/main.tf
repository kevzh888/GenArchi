// Récupération des données dans le fichier ssh_keys.txt
resource "aws_instance" "web_server" {
  // Définition de l'AMI à utiliser pour l'instance
  ami           = var.default-ami
  // Spécification du type d'instance
  instance_type = var.instance-type
  // Attribution d'un tag "Name" à l'instance
  tags = {
    Name = var.instance-name
  }
  
  // Association du groupe de sécurité à l'instance
  vpc_security_group_ids = [aws_security_group.security_group_module.id]

  // Récupération de toutes les clés SSH dans ssh_keys.txt et ajout dans ~/.ssh/authorized_keys de la VM créée
  user_data = <<-EOF
    #!/bin/bash
    sudo -u root bash -c 'echo "${data.local_file.ssh_public_keys.content}" >> ~/.ssh/authorized_keys'
  EOF
}

// Attribution d'une adresse IP élastique à la VM
resource "aws_eip" "elastic_ip" {
  // Association de l'IP élastique à l'instance créée
  instance = aws_instance.web_server.id
}
