
resource "aws_elastic_beanstalk_application" "deployer_eb_app" {
  name        = "deployer"
  description = "Securing DevOps Deployer Application"

}

data "aws_elastic_beanstalk_solution_stack" "docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) Docker (.*)$"
}

resource "aws_elastic_beanstalk_environment" "deployer_eb_env" {
  name                = "deployer-api"
  application         = aws_elastic_beanstalk_application.deployer_eb_app.name
  description         = "Deployer APP"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker.name
  tier                = "WebServer"

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_SECRET_ACCESS_KEY"
    value     = "Kd+xiJ62pyCUHUy/vt28yiR28+HM9aRLoFSh/val"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_ACCESS_KEY"
    value     = "AKIAUPS64SBAQ6EVJGUQ"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

}

resource "aws_s3_bucket" "deployer-eb" {
  bucket = "deployer-eb-1"
  acl    = "private"

  tags = {
    Name        = "Deployer APP Bucket"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket_object" "app-version-deployer" {
  bucket = aws_s3_bucket.deployer-eb.id
  key    = "deployer-app-version.json"
  source = "modules/deployer/deployer-app-version.json"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("modules/deployer/deployer-app-version.json")
}

resource "aws_elastic_beanstalk_application_version" "deployer_eb_app_version" {
  name        = "deployer_eb_app_version"
  application = aws_elastic_beanstalk_application.deployer_eb_app.name
  bucket      = aws_s3_bucket.deployer-eb.id
  key         = aws_s3_bucket_object.app-version-deployer.id

  provisioner "local-exec" {
    command = "aws elasticbeanstalk update-environment --environment-id ${aws_elastic_beanstalk_environment.deployer_eb_env.id} --version-label ${aws_elastic_beanstalk_application_version.deployer_eb_app_version.name}"
  }
}
