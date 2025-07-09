# ALB 생성
resource "aws_lb" "istory_alb" {
  name               = "istory-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.istory_alb_sg.id]
  subnets           = [for subnet in aws_subnet.dangtong-vpc-public-subnet : subnet.id]

  tags = {
    Name        = "istory-alb"
    Environment = "Production"
  }
}

# ALB 타겟 그룹
resource "aws_lb_target_group" "istory_tg" {
  name     = "istory-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.dangtong-vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "302"
    path               = "/actuator/health"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 2
  }
}

# ALB 리스너
resource "aws_lb_listener" "istory_listener" {
  load_balancer_arn = aws_lb.istory_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.istory_tg.arn
  }
} 