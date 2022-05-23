variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}



variable "access_ip" {
  type = string
}




#################### for database #############

variable "db_name" {
  type = string

}

variable "db_user" {
  type = string

}

# variable "db_subnet_group_name" {
#   type = string
# }

variable "db_password" {
  type = string
}