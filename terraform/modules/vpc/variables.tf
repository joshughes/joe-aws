variable "name" { }
variable "cidr" { }
variable "public_fe_subnets" { default = "" }
variable "private_app_subnets" { default = "" }
variable "private_db_subnets" { default = "" }
variable "azs" { }
variable "aws_key_name" { }
variable "networkprefix" { }
variable "aws_key_location" { }
variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default = true
}
variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default = true
}
