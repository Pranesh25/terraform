###### database main file

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  name                 = var.db_name
  username             = var.db_user
  password             = var.db_password
  db_subnet_group_name = module.vpc.aws_db_subnet_group_name[0]
  vpc_security_group_ids = module.vpc.vpc_security_group_ids
  publicly_accessible    = false

  skip_final_snapshot  = var.db_skip_snapshot
  tags = {
    "Name" = "pranesh-db"
  }
}



# resource "aws_s3_bucket" "backend_storage" {

#   bucket = "terraform-state-pranesh"

#   lifecycle {
#     prevent_destroy = true 
#   }

#   versioning {
#     enabled = true 
#   }

# server_side_encryption_configuration {
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm  = "AES256"
#     }
#   }
#  } 

  
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
#     region = "us-east-1"
#     dynamodb_table = "terraform_state_lock"
#     encrypt = true 
#   }
# }