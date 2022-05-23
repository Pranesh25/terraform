locals {
  vpc_cidr = "192.168.0.0/16"
}

locals {

  security_group = {
    public = {
      name        = "public_sg"
      description = "security group for public access"
      ingress = {
        ssh = {
          from       = 22
          to         = 22
          protocol   = "tcp"
          cidr_block = [var.access_ip]
        }

        http = {
          from       = 80
          to         = 80
          protocol   = "tcp"
          cidr_block = ["0.0.0.0/0"]
        }


      }
    }

    rds = {
      name        = "rds-sg"
      description = "sg- for-rds"
      ingress = {
        mysql = {
          from       = 3306
          to         = 3306
          protocol   = "tcp"
          cidr_block = [local.vpc_cidr]
        }

      }
    }



  }
}