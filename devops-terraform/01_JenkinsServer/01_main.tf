resource "aws_instance" "web" {
  ami                    = "ami-0866a3c8686eaeeba"   
  instance_type          = "t2.xlarge"               
  key_name               = "My-Key-Pair-2024"        
  vpc_security_group_ids = [aws_security_group.My-Jenkins-Server-SG.id]
  user_data              = templatefile("./03_install.sh", {}) 

  tags = {
    Name = "My-Jenkins-Server" 
  }

  root_block_device {
    volume_size = 20
  }

}




resource "aws_security_group" "My-Jenkins-Server-SG" {
  name        = "My-Jenkins-Server-SG" #
  description = "Allow TLS inbound traffic"

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My-Jenkins-Server-SG"
  }

}



