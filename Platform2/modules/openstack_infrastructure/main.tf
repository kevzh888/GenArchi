provider "openstack" {
  cloud = "openstack"
}

resource "openstack_networking_secgroup_v2" "my_secgroup" {
  name        = "my-secgroup"
  description = "Security group for terraform VMs"
}

resource "openstack_networking_secgroup_rule_v2" "allow_ssh" {
  security_group_id = openstack_networking_secgroup_v2.my_secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0" # Allow SSH access from any IP address
}

resource "openstack_networking_secgroup_rule_v2" "allow_tcp" {
  security_group_id = openstack_networking_secgroup_v2.my_secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0" # Allow TCP access from any IP address
}

resource "openstack_networking_secgroup_rule_v2" "allow_mysql" {
  security_group_id = openstack_networking_secgroup_v2.my_secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "0.0.0.0/0" # Allow TCP access from any IP address
}

resource "openstack_networking_secgroup_rule_v2" "allow_icmp" {
  security_group_id = openstack_networking_secgroup_v2.my_secgroup.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0" # Allow ICMP traffic from any IP address
}

resource "openstack_networking_secgroup_rule_v2" "allow_all_outbound_tcp" {
  security_group_id = openstack_networking_secgroup_v2.my_secgroup.id
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "allow_all_outbound_udp" {
  security_group_id = openstack_networking_secgroup_v2.my_secgroup.id
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "allow_all_outbound_icmp" {
  security_group_id = openstack_networking_secgroup_v2.my_secgroup.id
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "public"
  address = "172.24.4.133"
}

resource "openstack_compute_floatingip_associate_v2" "bridge" {
  floating_ip = openstack_networking_floatingip_v2.myip.address
  instance_id = openstack_compute_instance_v2.openstack-vm-masterdb-tf.id
}

resource "openstack_networking_floatingip_v2" "myip2" {
  pool = "public"
  address = "172.24.4.161"
}

resource "openstack_compute_floatingip_associate_v2" "bridge2" {
  floating_ip = openstack_networking_floatingip_v2.myip2.address
  instance_id = openstack_compute_instance_v2.openstack-vm-slavedb-tf.id
}


resource "openstack_compute_keypair_v2" "ssh_keypair" {
  name       = "ssh-keypair"
  public_key = file("/home/stack/.ssh/id_rsa.pub")
}

resource "openstack_compute_instance_v2" "openstack-vm-masterdb-tf" {
  name = "openstack-vm-masterdb-tf"
  //access_ip_v4 = "34.155.51.153"
  image_name      = "16.04"
  flavor_name     = "m1.small"
  key_pair        = openstack_compute_keypair_v2.ssh_keypair.name
  security_groups = [openstack_networking_secgroup_v2.my_secgroup.name]

  network {
    name = "private"
  }

}

resource "openstack_compute_instance_v2" "openstack-vm-slavedb-tf" {
  name = "openstack-vm-slavedb-tf"
  //access_ip_v4 = "34.155.51.153"
  image_name      = "16.04"
  flavor_name     = "m1.small"
  key_pair        = openstack_compute_keypair_v2.ssh_keypair.name
  security_groups = [openstack_networking_secgroup_v2.my_secgroup.name]

  network {
    name = "private"
  }

}