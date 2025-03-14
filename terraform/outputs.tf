output "cname" {
  value = module.invoicer_db.cname
}

output "env_name" {
  value = module.invoicer_db.env_name
}

output "env_id" {
  value = module.invoicer_db.env_id
}

output "app_version" {
  value = module.invoicer_db.app_version
}

output "deployer_cname" {
  value = module.deployer.cname
}

output "deployer_env_name" {
  value = module.deployer.env_name
}

output "deployer_env_id" {
  value = module.deployer.env_id
}

output "deployer_app_version" {
  value = module.deployer.app_version
}

output "security_group_db" {
  value = aws_security_group.invoicer_db.id
}

output "security_group_ec" {
  value = aws_security_group.invoicer_ec.id
}

output "security_group_lb" {
  value = aws_security_group.invoicer_lb.id
}
output "bastion_public_dns" {
  value = module.bastion.public_dns
}
output "bastion_public_ip" {
  value = module.bastion.public_ip
}
