resource "aws_db_instance" "default" {
  name                       = "invoicer"
  identifier                 = var.db_app
  vpc_security_group_ids     = var.security_groups
  allocated_storage          = 5
  instance_class             = var.db_instance_type
  engine                     = "postgres"
  engine_version             = "9.6.2"
  auto_minor_version_upgrade = true
  publicly_accessible        = true
  username                   = "invoicer"
  password                   = "is=P2xeDth.=-0"
  multi_az                   = false
  skip_final_snapshot        = true

  tags = {
    environment-name = "invoicer-api"
  }
}

resource "aws_elastic_beanstalk_application" "invoicer_eb_app" {
  name        = "invoicer"
  description = "Securing DevOps Invoicer Application"

}

data "aws_elastic_beanstalk_solution_stack" "docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) Docker (.*)$"
}

resource "aws_elastic_beanstalk_environment" "invoicer_eb_env" {
  name                = "invoicer-api"
  application         = aws_elastic_beanstalk_application.invoicer_eb_app.name
  description         = "Invoicer APP"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker.name
  tier                = "WebServer"

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "INVOICER_POSTGRES_USER"
    value     = "invoicer"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "INVOICER_POSTGRES_PASSWORD"
    value     = "is=P2xeDth.=-0"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "INVOICER_POSTGRES_DB"
    value     = "invoicer"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "INVOICER_POSTGRES_HOST"
    value     = aws_db_instance.default.address
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

}

resource "aws_s3_bucket" "invoicer-eb" {
  bucket = "invoicer-eb-1"
  acl    = "private"

  tags = {
    Name        = "Invoicer APP Bucket"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket_object" "app-version" {
  bucket = aws_s3_bucket.invoicer-eb.id
  key    = "app-version.json"
  source = "../app-version.json"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("../app-version.json")
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "invoicer_eb_app_version"
  application = aws_elastic_beanstalk_application.invoicer_eb_app.name
  bucket      = aws_s3_bucket.invoicer-eb.id
  key         = aws_s3_bucket_object.app-version.id

  provisioner "local-exec" {
    command = "aws elasticbeanstalk update-environment --environment-id ${aws_elastic_beanstalk_environment.invoicer_eb_env.id} --version-label ${aws_elastic_beanstalk_application_version.default.name}"
  }
}

#############################################
# COMMENTED OUT FROM HERE *******************
#############################################

/*

resource "aws_elb" "this" {
  name            = "${var.db_app}-web"
  subnets         = var.subnets
  security_groups = var.security_groups

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.web_app}-web"
  image_id      = var.web_image_id
  instance_type = var.db_instance_type
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_autoscaling_group" "this" {
  availability_zones  = ["us-west-2a"," us-west-2b"]
  vpc_zone_identifier = var.subnets
  desired_capacity    = var.web_desired_capacity
  max_size            = var.web_max_size
  min_size            = var.web_min_size

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  elb                    = aws_elb.this.id
}
*/
