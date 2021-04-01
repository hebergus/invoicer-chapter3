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

resource "aws_security_group" "invoicer_lb" {
  name        = "invoicer_lb"
  description = "Invoicer EB compute security group"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
}

resource "aws_security_group" "invoicer_ec" {
  name        = "invoicer_ec"
  description = "Invoicer EB compute security group"


  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.invoicer_lb.id]
    cidr_blocks     = var.whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
}

resource "aws_security_group" "invoicer_db" {
  name        = "invoicer_db"
  description = "Invoicer database security group"


  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.invoicer_ec.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" : "true"
  }
}

module "invoicer_db" {
  source = "./modules/invoicer_db"

  db_instance_type = var.db_instance_type
  invoicer_vpc     = aws_default_vpc.default.id
  subnets          = [aws_default_subnet.default_az1.id]
  security_groups  = [aws_security_group.invoicer_lb.id, aws_security_group.invoicer_ec.id, aws_security_group.invoicer_db.id]
  db_app           = "invoicerdb"
}

module "deployer" {
  source = "./modules/deployer"

}
