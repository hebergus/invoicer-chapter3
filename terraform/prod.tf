variable "whitelist" {
  type = list(string)
}
variable "db_instance_type" {
  type = string
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "eu-west-2a"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_security_group" "invoicer_db" {
  name        = "invoicer_db"
  description = "Invoicer database security group"


  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }

  tags = {
    "Terraform" : "true"
  }
}

module "invoicer_db" {
  source = "./modules/invoicer_db"

  db_instance_type = var.db_instance_type
  subnets          = [aws_default_subnet.default_az1.id]
  security_groups  = [aws_security_group.invoicer_db.id]
  db_app           = "invoicerdb"
}

module "deployer" {
  source = "./modules/deployer"

}
