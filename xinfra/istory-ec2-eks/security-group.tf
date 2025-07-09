resource "aws_security_group" "istory_nginx_sg" {
  name_prefix = "istory nginx sg"
  vpc_id      = aws_vpc.dangtong-vpc.id 

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS 보안 그룹 추가
resource "aws_security_group" "istory_rds_sg" {
  name_prefix = "istory rds sg"
  vpc_id      = aws_vpc.dangtong-vpc.id

  ingress {
    description     = "Allow MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [
      aws_security_group.istory_prod_ec2_sg.id # Autoscaling 그룹 보안 그룹 추가
      ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "istory-rds-sg"
  }
}

# ALB 보안 그룹
resource "aws_security_group" "istory_alb_sg" {
  name_prefix = "istory alb sg"
  vpc_id      = aws_vpc.dangtong-vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "istory-alb-sg"
  }
}

# EC2 보안 그룹 수정 - ALB에서만 접근 허용
resource "aws_security_group" "istory_prod_ec2_sg" {
  name_prefix = "istory prod ec2 sg"
  vpc_id      = aws_vpc.dangtong-vpc.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.istory_alb_sg.id]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "istory-prod-ec2-sg"
  }
}
