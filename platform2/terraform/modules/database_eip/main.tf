# modules/eip/main.tf

resource "aws_eip" "master_eip" {
  vpc = true
}

/*resource "aws_eip" "slave_eip" {
  vpc = true
}*/
