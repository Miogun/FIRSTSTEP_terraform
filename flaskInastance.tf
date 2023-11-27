resource "aws_instance" "flaskServer" {
    ami = "ami-086cae3329a3f7d75"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet_2a.id
    key_name = aws_key_pair.my_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.flask_sg.id]
    associate_public_ip_address = true

    # 인스턴스에 IAM 역할 할당
    iam_instance_profile = aws_iam_instance_profile.flask_profile.name
    user_data = <<EOF
    #!/bin/bash
    sudo apt-get update
    sudo spt-get install -y php
    sudo systemctl restart apache2
    sudo apt update
    sudo apt install -y ruby-full
    sudo apt install wget
    cd /home/ubuntu
    wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
    sudo ./install auto
    EOF
    tags = {
      Name = "flaskServer"
    }
}

# RSA private 키 생성
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "my_key_pair" {
  key_name = "myKeyPair"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "my_downloads_key" {
  filename = "myKeyPair.pem"
  content = tls_private_key.my_key.private_key_pem
}

# 보안그룹 생성
resource "aws_security_group" "flask_sg" {
  name_prefix = "flask_sg"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "flask_sg_ingress_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}

resource "aws_security_group_rule" "flask_sg_ingress_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}
resource "aws_security_group_rule" "flask_sg_ingress_flask" {
  type = "ingress"
  from_port = 5000
  to_port = 5000
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}
resource "aws_security_group_rule" "flask_sg_egress_mysql" {
   type = "egress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}
resource "aws_security_group_rule" "flask_sg_egress_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}

# 역할생성
resource "aws_iam_role" "flask_role" {
  name = "flask_role"
  assume_role_policy = <<EOF
{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
} 
  
# AmazonS3FullAccess 정책을 연결
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.flask_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# EC2 인스턴스 프로필 생성 및 역할 연결
resource "aws_iam_instance_profile" "flask_profile" {
  name = "flask-instance-profile"
  role = aws_iam_role.flask_role.name
}

output "flask_ip" {
  value = aws_instance.flaskServer.public_ip
}
output "access_key" {
  value = tls_private_key.my_key.private_key_pem
  sensitive = true
}