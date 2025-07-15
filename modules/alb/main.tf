data "aws_caller_identity" "current" {}

# ALB용 ACM 인증서 발급 및 검증 (서울 리전)
data "aws_route53_zone" "main" {
  name         = var.domain_name 
  private_zone = false
}

# 1. ALB 생성 (인터넷-facing)
resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  access_logs {
    bucket  = var.alb_logs_bucket_name
    prefix  = "alb-logs"
    enabled = true
  }

  tags = merge(tomap({
        Name =  "alb-${var.stage}-${var.servicename}"}), var.tags)
}

# 1.1 route53 레코드 생성 
resource "aws_route53_record" "alb_root" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"      
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}


# 2. Target Groups
resource "aws_lb_target_group" "alb_tg_spring" {
  name        = "alb-tg-spring"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path = "/health"
    matcher = "200"
  }
}

resource "aws_lb_target_group" "alb_tg_fastapi" {
  name        = "alb-tg-fastapi"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path = "/health"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "spring" {
  target_group_arn = aws_lb_target_group.alb_tg_spring.arn
  target_id        = var.instance_id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "fastapi" {
  target_group_arn = aws_lb_target_group.alb_tg_fastapi.arn
  target_id        = var.instance_id
  port             = 8000
}

# 3. ALB Listener (http:포트 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# 3.1 ALB Listener (https:포트 443)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
      message_body = "Not Found"
    }
  }
}


resource "aws_lb_listener_rule" "fastapi_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_fastapi.arn
  }

  condition {
    path_pattern {
      values = ["/api/ai/*"]
    }
  }
}

resource "aws_lb_listener_rule" "springboot_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_spring.arn
  }

  condition {
    path_pattern {
      values = ["/api/backend/*"]
    }
  }
}

