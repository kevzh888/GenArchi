// Retrieve datas in the ssh_keys.txt file
resource "aws_instance" "web_server" {
  ami           = var.default-ami
  instance_type = var.instance-type
  tags = {
    Name = var.instance-name
  }
  
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  // Retrieve all ssh keys in ssh_keys.txt and put it in the created VM at ~/.ssh/authorized_keys
  user_data = <<-EOF
    #!/bin/bash
    sudo -u root bash -c 'echo "${data.local_file.ssh_public_keys.content}" >> ~/.ssh/authorized_keys'
  EOF
}
// attribute an elastic Ip to the VM
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.web_server.id
}
