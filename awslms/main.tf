


module "vpc" {
  source               = "./networking"
  access_ip            = var.access_ip
  security_groups      = local.security_group
  vpc_cidr             = local.vpc_cidr
  private_subnet_count = 4
  public_subnet_count  = 4
  max_subnets          = 20
  public_cidrs         = [for i in range(2, 10, 2) : cidrsubnet(local.vpc_cidr, 8, i)] #for public
  private_cidrs        = [for i in range(1, 9, 2) : cidrsubnet(local.vpc_cidr, 8, i)]  #for private
  aws_db_subnet_group  = true



}


# module "database" {
#   source                 = "./database"
#   db_storage             = 10
#   db_instance_class      = "db.t2.micro"
#   db_name                = var.db_name
#   db_user                = var.db_user
#   db_password            = var.db_password
#   db_engine_version      = "5.7.22"
#   db_identifier          = "db-idenfier"
#   db_skip_snapshot       = "true"
#   db_subnet_group_name   = module.vpc.db_subnet_group_name[0]
#   vpc_security_group_ids = module.vpc.db_security_group



# }

# resource "aws_s3_bucket" "backend_storage" {

#   bucket = "terraform-state-pranesh"

#   lifecycle {
#     prevent_destroy = true 
#   }

# versioning {
#   enabled = true 
# }

# server_side_encryption_configuration {
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm  = "AES256"
#     }
#   }
#  }  
# }

# resource "aws_s3_bucket_versioning" "versioning" {
#   bucket = aws_s3_bucket.backend_storage.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }


# resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
#   bucket = aws_s3_bucket.backend_storage.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm  = "AES256"
#     }
#   }

# }


# resource "aws_dynamodb_table" "terraform_lock" {
#   name = "terraform_state_lock"
#   billing_mode = "PROVISIONED"
#   hash_key = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# terraform {
#   backend "s3" {
#     bucket = "terraform-state-pranesh"
#     key = "global/s3/terraform.tfstate"
#     # skip_credentials_validation = true
#     # skip_metadata_api_check     = true
#     # force_path_style            = true
#     region = "us-east-1"
#     dynamodb_table = "terraform_state_lock"
#     encrypt = true 
#   }
# }


module "loadbalancing" {
  source                 = "./loadbalancer"
  public_sg              = module.vpc.public_sg
  public_subnets         = module.vpc.public_subnets
  tg_port                = 80
  tg_protocol            = "HTTP"
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 300
  vpc_id                 = module.vpc.vpc_id
  listener_port = 80
  listener_protocol =  "HTTP"


}



module "compute" {
  source = "./compute"
  public_sg = module.loadbalancing.public_sg
  public_subnets = module.loadbalancing.public_subnets
  instance_count = 1
  instance_type = "t2.micro"
  vol_size = 10 
  key_name = "yourkeyname"
  public_key_path = "your path to public key"
  #ssh-keygen -t rsa
  user_data_path = "${path.root}/userdata.tpl"
  db_user = var.db_user
     db_pass = var.db_pass 
     dbname = var.db_name
     db_endpoint = module.database.db_endpoint
     target_group_arn = module.loadbalancing.alb_target_group_arn
  
}