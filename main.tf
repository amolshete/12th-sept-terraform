terraform {

  backend "s3" {
    bucket = "22th-sept-terraform-state-bucket-123"
    key    = "path/terraform.tfstate"
    region = "ap-south-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}
 

# resource "aws_instance" "demo-instance" {
#   ami           = "ami-05552d2dcf89c9b24"
#   instance_type = "t2.micro"
#   key_name = "linux-os-key"

#   tags = {
#     Name = "demo machine from terraform"
#   }
# }


# #eip
# resource "aws_eip" "lb" {
#   instance = aws_instance.demo-instance.id
# }


#Creating the new infrastructure
resource "aws_vpc" "mumbai_vpc" {
  cidr_block = "10.10.0.0/16"

 tags = {
    Name = "Mumbai_VPC"
  }
}

#subenet


resource "aws_subnet" "mumbai_subnet_1a" {
  vpc_id     = aws_vpc.mumbai_vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mumbai_subnet_1a"
  }
}


resource "aws_subnet" "mumbai_subnet_1b" {
  vpc_id     = aws_vpc.mumbai_vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"
  
  tags = {
    Name = "mumbai_subnet_1b"
  }
}


resource "aws_subnet" "mumbai_subnet_1c" {
  vpc_id     = aws_vpc.mumbai_vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1c"
  
  tags = {
    Name = "mumbai_subnet_1c"
  }
}

#instance 

resource "aws_instance" "web-1" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai_keys.id
  subnet_id = aws_subnet.mumbai_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "Webserver-1"
  }
}

resource "aws_instance" "web-2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai_keys.id
  subnet_id = aws_subnet.mumbai_subnet_1b.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  
  tags = {
    Name = "Webserver-2"
  }
}


resource "aws_instance" "web-3" {
  ami           = "ami-009715c29e3b187cb"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai_keys.id
  subnet_id = aws_subnet.mumbai_subnet_1b.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  
  tags = {
    Name = "Webserver-3"
  }
}

#keypair
resource "aws_key_pair" "mumbai_keys" {
  key_name   = "mumbai_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDU5eGo1k43rGh5qKodhkfFPIGyTMPckhHKCD4QnfikCpHYmqnW4QTgTgy8ubv7tYi3LKAfPp4SOKRPRjDa1krLpPlOT52/BSHVRrOB6rxuueo8zy2hRcIkaxDT6p1hob1Ob0HHw8wkAN7PSyRBt0Xk9OiIbff74K2MsXm9FKaMA2dCB7lrLIej1TubVbEH1+TNkRlqjlVWvd38DNoVTHwLWcGFa648RuH46VgigptglFHz/i2YQP0T+6zlWyg8sD65G96SWTBxosieOg7hLs8t6GtC4GTQ+nxXMqdrVPFpTXg7fo96jXwPLnwh5TjE6Hd4DFlN+EL+ujhgOqLzPc09ODVpxksHrZd597LZNkMZrv8fGMpkUw2KIYv9Ee8O+5fIhv0W2QJhTIYm7mgsi1noEdiJZKWgSaPKEPw2ZsZ8c3dgJQ+YDEWlSckNtYEyoQ4+ouXEXAV0K3UOZzh6YGfwHqxG1VxAaGVOb5a4kyeznXvnnnBcI6tYHuhMEo3DEXM= Amol@DESKTOP-2MVQBON"
}

#security group

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_http_ssh"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.mumbai_vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

#create IG

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mumbai_vpc.id

  tags = {
    Name = "Mumbai-vpc-IG"
  }
}

#RT

resource "aws_route_table" "mumbai_RT_Public" {
  vpc_id = aws_vpc.mumbai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "mumbai-RT-Public"
  }
}


resource "aws_route_table" "mumbai_RT_Private" {
  vpc_id = aws_vpc.mumbai_vpc.id

  tags = {
    Name = "mumbai-RT-Private"
  }
}

resource "aws_route_table_association" "RT_asso_1a" {
  subnet_id      = aws_subnet.mumbai_subnet_1a.id
  route_table_id = aws_route_table.mumbai_RT_Public.id
}

resource "aws_route_table_association" "RT_asso_1b" {
  subnet_id      = aws_subnet.mumbai_subnet_1b.id
  route_table_id = aws_route_table.mumbai_RT_Public.id
}

resource "aws_route_table_association" "RT_asso_1c" {
  subnet_id      = aws_subnet.mumbai_subnet_1c.id
  route_table_id = aws_route_table.mumbai_RT_Private.id
}

#target group 

resource "aws_lb_target_group" "card-website-TG-terraform" {
  name     = "card-website-TG-terraform"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mumbai_vpc.id
}


resource "aws_lb_target_group_attachment" "TG-instance-1" {
  target_group_arn = aws_lb_target_group.card-website-TG-terraform.arn
  target_id        = aws_instance.web-1.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "TG-instance-2" {
  target_group_arn = aws_lb_target_group.card-website-TG-terraform.arn
  target_id        = aws_instance.web-2.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "TG-instance-3" {
  target_group_arn = aws_lb_target_group.card-website-TG-terraform.arn
  target_id        = aws_instance.web-3.id
  port             = 80
}

#LB 

resource "aws_lb" "card-website-LB-terraform" {
  name               = "card-website-LB-terraform"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh_http.id]
  subnets            = [aws_subnet.mumbai_subnet_1a.id, aws_subnet.mumbai_subnet_1b.id]


  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "card-website-listener" {
  load_balancer_arn = aws_lb.card-website-LB-terraform.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.card-website-TG-terraform.arn
  }
}

######creating the instances via ASG and we will attach the LB to it


resource "aws_launch_template" "LT-demo-terraform" {
  name = "LT-demo-terraform"
  image_id = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai_keys.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  user_data = filebase64("example.sh")


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "demo-instance by terra"
    }
  }
}

# asg creation

resource "aws_autoscaling_group" "demo-asg" {
  vpc_zone_identifier = [aws_subnet.mumbai_subnet_1a.id, aws_subnet.mumbai_subnet_1b.id]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  name = "demo-as-terraform"
  target_group_arns = [aws_lb_target_group.card-website-TG-terraform-2.arn]

  launch_template {
    id      = aws_launch_template.LT-demo-terraform.id
    version = "$Latest"
  }
}

# LB with ASG

resource "aws_lb_target_group" "card-website-TG-terraform-2" {
  name     = "card-website-TG-terraform-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mumbai_vpc.id
}


resource "aws_lb_listener" "card-website-listener-2" {
  load_balancer_arn = aws_lb.card-website-LB-terraform-2.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.card-website-TG-terraform-2.arn
  }
}
 

resource "aws_lb" "card-website-LB-terraform-2" {
  name               = "card-website-LB-terraform-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh_http.id]
  subnets            = [aws_subnet.mumbai_subnet_1a.id, aws_subnet.mumbai_subnet_1b.id]


  tags = {
    Environment = "production"
  }
}