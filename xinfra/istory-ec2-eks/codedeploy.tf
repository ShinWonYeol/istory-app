# CodeDeploy 애플리케이션 생성
resource "aws_codedeploy_app" "istory-app" {
  name = "istory-app"
}

resource "aws_codedeploy_deployment_group" "istory_prod_deploy_group" {
  app_name               = aws_codedeploy_app.istory-app.name
  deployment_group_name  = "istory-prod-deploy-group"
  # codeploy가 ec2의 상태를 모니터링 할 수 있음
  service_role_arn      = aws_iam_role.codedeploy_service_role.arn

  deployment_style {
    # 대상을 로드밸런스에서 때었다 붙이겠다.
    deployment_option = "WITH_TRAFFIC_CONTROL"
    # 기존 인스턴스에 직접 덮어쓰기(중지 및 시작)
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      # 배포 할 대상 그룹 정보
      name = aws_lb_target_group.istory_tg.name
    }
  }

  auto_rollback_configuration {
    # 롤백 정책 사용
    enabled = true
    # 배포 실패 시 롤백 시작
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ec2_tag_set {
    # 해당 태그를 가진 인스턴스들만 배포 대상으로 인식하겠다
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "Production"
    }
  }

  trigger_configuration {
    # 성공, 실패시 sns 를 설정
    trigger_events = ["DeploymentSuccess", "DeploymentFailure"]
    trigger_name   = "prod-deployment-trigger"
    trigger_target_arn = aws_sns_topic.deployment_notifications.arn
  }

  alarm_configuration {
    enabled = true
    alarms  = ["istory-prod-deployment-alarm"]
  }
}

# SNS 토픽 생성
resource "aws_sns_topic" "deployment_notifications" {
  name = "istory-deployment-notifications"
}

output "prod_alb_dns" {
  value       = aws_lb.istory_alb.dns_name
  description = "The DNS name of the production ALB"
}

output "prod_deployment_group_name" {
  value       = aws_codedeploy_deployment_group.istory_prod_deploy_group.deployment_group_name
  description = "Name of the production CodeDeploy deployment group"
}
