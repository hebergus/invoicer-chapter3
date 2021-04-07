resource "aws_network_interface" "bastion_iface" {
  subnet_id       = "subnet-36e78d4c"
  security_groups = [element(var.security_groups, 0)]

  tags = {
    Name = "bastion primary_network_interface"
  }
}

resource "aws_key_pair" "bastion_keys" {
  key_name   = "bastion_keys"
  public_key = file("modules/bastion/mykey_ecdsa.pub")
}

resource "aws_instance" "bastion" {
  ami           = "ami-0fbec3e0504ee1970"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion_keys.key_name

  network_interface {
    network_interface_id = aws_network_interface.bastion_iface.id
    device_index         = 0
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }

  tags = {
    Name = "bastion"
    "Terraform" : "true"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ${var.pvt_key_location} bastion-2FA-ansible.yml"
  }
}
