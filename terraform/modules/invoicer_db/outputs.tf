
output "cname" {
  value = aws_elastic_beanstalk_environment.invoicer_eb_env.cname
}

output "env_name" {
  value = aws_elastic_beanstalk_environment.invoicer_eb_env.name
}

output "env_id" {
  value = aws_elastic_beanstalk_environment.invoicer_eb_env.id
}

output "app_version" {
  value = aws_elastic_beanstalk_application_version.default.name
}
