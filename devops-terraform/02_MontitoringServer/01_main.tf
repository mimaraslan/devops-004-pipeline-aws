resource "aws_instance" "web" {
  ami                    = "ami-0866a3c8686eaeeba"   
  instance_type          = "t2.large"               
  key_name               = "My-Key-Pair-2024"        
  vpc_security_group_ids = [aws_security_group.My-Monitoring-Server-SG.id]
  user_data              = templatefile("./03_install.sh", {}) 

  tags = {
    Name = "My-Monitoring-Server" 
  }

  root_block_device {
    volume_size = 20
  }

}




resource "aws_security_group" "My-Monitoring-Server-SG" {
  name        = "My-Monitoring-Server-SG" #
  description = "Allow TLS inbound traffic"

  ingress = [
    for port in [22, 80, 443, 9090, 9100, 3000] : {
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
    Name = "My-Monitoring-Server-SG"
  }

}





resource "aws_budgets_budget" "budget-ec2" {
  name              = "my-monthly-budget"
  budget_type       = "COST"
  limit_amount      = "80"
  limit_unit        = "USD"
  time_period_start = "2024-10-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 70
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["mimar.aslan@gmail.com"]
  }
}