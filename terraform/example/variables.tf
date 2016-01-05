variable "azs" {
  default = "us-east-1a,us-east-1b,us-east-1e"
}

variable "app_subnets" {
  default = {
    "0" = "subnet-22d0d955"
    "1" = "subnet-213a1978"
    "2" = "subnet-62194849"
  }
}

variable "vpc_cidr" {
  default = "10.249.0.0/16"
}

variable "vpc_name" {
  default = "example"
}

variable "ami" {
}
