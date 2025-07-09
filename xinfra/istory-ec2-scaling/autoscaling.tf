# Auto Scaling Group
resource "aws_autoscaling_group" "istory_asg" {
  name                = "istory-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.istory_tg.arn]
  vpc_zone_identifier = [for subnet in aws_subnet.dangtong-vpc-public-subnet : subnet.id]

  launch_template {
    id      = aws_launch_template.istory_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}