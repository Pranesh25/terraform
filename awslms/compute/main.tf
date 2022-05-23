########## compute /main.tf ####

data "aws_ami" "pranesh-ami" {
    most_recent = true
    owners = [ "012312" ]

    filter {
      name = "name"
      values = ["ami-name froom amazon remove the last digit and add -*"]
      
    }
  
}


resource "random_id" "node_id" {
    byte_length = 2
    count = var.instance_count

    keepers = {
        key_name = var.key_name
    }
     
}


resource "aws_key_pair" "aws_key" {
    key_name = var.key_name  
    public_key = file(var.public_key_path)
  
}

resource "aws_instance" "pranesh_node" {
  count = var.instance_count
  instance_type = var.instance_type
  ami = data.aws_ami.pranesh-ami.id
  tags = {
    "Name" = "pranesh-node-${random_id.node_id[count.index].dec}"

  }

 keyname = aws_key_pair.aws_key.id
 vpc_security_group_ids = [var.public_sg]
 subnet_id = var.public_subnets[count.index]
 user_data = templatefile(var.user_data_path,
 {
     nodename = "pranesh-node-${random_id.node_id[count.index].dec}"
     db_endpoint = var.db_endpoint
     db_user = var.db_user
     db_pass = var.db_pass 
     dbname = var.db_name
 }
 )
 root_block_device {
    volume_size = var.vol_size #8

  }
}

resource "aws_alb_target_group_attachment" "attachement" {
    count = var.instance_count
    target_group_arn = var.alb_target_group_arn
    target_id = aws_instance.pranesh_node[count.index].id
    port =8000
  
}