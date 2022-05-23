############# loadbalacner / variable.tf ##############

variable "public_sg" {
  
}

variable "public_subnets" {
  
}



########################### target group
variable "tg_port" {}
variable "tg_protocol" {}
variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}


############################# listener

variable "listener_port" {}
variable "listener_protocol" {}


