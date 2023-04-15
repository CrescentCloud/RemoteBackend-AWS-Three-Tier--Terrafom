# --- loadbalancing/main.tf ---


# INTERNET FACING LOAD BALANCER

resource "aws_lb" "awsprod_lb" {
  name            = "awsprod-loadbalancer"
  security_groups = [var.lb_sg]
  subnets         = var.public_subnets
  idle_timeout    = 400

  depends_on = [
    var.app_asg
  ]
}

resource "aws_lb_target_group" "awsprod_tg" {
  name     = "awsprod-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id

  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "awsprod_lb_listener" {
  load_balancer_arn = aws_lb.awsprod_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.awsprod_tg.arn
  }
}

resource "aws_route53_zone" "primary" {
  name = "illusiveidea.com"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "illusiveidea.com"
  type    = "A"

  alias {
    name                   = aws_lb.awsprod_lb.dns_name
    zone_id                = aws_lb.awsprod_lb.zone_id
    evaluate_target_health = true
  }
}

# --- loadbalancing/outputs.tf --- 

output "alb_dns" {
  value = aws_lb.awsprod_lb.dns_name
}

output "lb_endpoint" {
  value = aws_lb.awsprod_lb.dns_name
}

output "lb_tg_name" {
  value = aws_lb_target_group.awsprod_tg.name
}

output "lb_tg" {
  value = aws_lb_target_group.awsprod_tg.arn
}

# --- loadbalancing/variables.tf ---

variable "lb_sg" {}
variable "public_subnets" {}
variable "app_asg" {}
variable "tg_port" {}
variable "tg_protocol" {}
variable "vpc_id" {}
variable "listener_port" {}
variable "listener_protocol" {}
# variable "azs" {}

