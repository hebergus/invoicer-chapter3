variable "db_instance_type" {
  type = string
}
variable "subnets" {
  type = list(string)
}
variable "security_groups" {
  type = list(string)
}
variable "invoicer_vpc" {
  type = string
}
variable "db_app" {
  type = string
}

/*
variable "web_image_id" {
  type = string
}
variable "web_desired_capacity" {
  type = number
}
variable "web_max_size" {
  type = number
}
variable "web_min_size" {
  type = number
}
*/
