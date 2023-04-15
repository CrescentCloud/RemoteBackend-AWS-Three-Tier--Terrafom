# LATEST AMI FROM PARAMETER STORE

data "aws_ssm_parameter" "aws-prod-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR bastionhost

resource "aws_launch_template" "aws_prod_bastionhost" {
  name_prefix            = "awsprod_bastionhost"
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.aws-prod-ami.value
  vpc_security_group_ids = [var.bastionhost_sg]
  key_name               = var.key_name

  tags = {
    Name = "aws-prod-bastionhost"
  }
}

resource "aws_autoscaling_group" "aws_prod_bastionhost" {
  name                = "awsprod-bastionhost"
  vpc_zone_identifier = var.public_subnets
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.aws_prod_bastionhost.id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR FRONTEND APP TIER

resource "aws_launch_template" "awsprod_app" {
  name_prefix            = "awsprod_app"
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.aws-prod-ami.value
  vpc_security_group_ids = [var.frontend_app_sg]
  user_data              = filebase64("install_apache.sh")
  key_name               = var.key_name

  tags = {
    Name = "aws-prod-app"
  }
}

data "aws_lb_target_group" "awsprod_tg" {
  name = var.lb_tg_name
}

resource "aws_autoscaling_group" "awsprod_app" {
  name                = "awsprod_app"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  target_group_arns = [data.aws_lb_target_group.awsprod_tg.arn]

  launch_template {
    id      = aws_launch_template.awsprod_app.id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BACKEND

resource "aws_launch_template" "awsprod_backend" {
  name_prefix            = "awsprod_backend"
  instance_type          = var.instance_type
  image_id               = data.aws_ssm_parameter.aws-prod-ami.value
  vpc_security_group_ids = [var.backend_app_sg]
  key_name               = var.key_name
  user_data              = filebase64("install_node.sh")

  tags = {
    Name = "aws-prod-backend"
  }
}

resource "aws_autoscaling_group" "awsprod_backend" {
  name                = "awsprod_backend"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.awsprod_backend.id
    version = "$Latest"
  }
}

# AUTOSCALING ATTACHMENT FOR APP TIER TO LOADBALANCER

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.awsprod_app.id
  lb_target_group_arn    = var.lb_tg
}

# --- compute/variables.tf ---

variable "bastionhost_sg" {}
variable "frontend_app_sg" {}
variable "backend_app_sg" {}
variable "private_subnets" {}
# variable "public_subnets" {}
variable "key_name" {}
variable "lb_tg_name" {}
variable "lb_tg" {}

variable "bastionhost_instance_count" {
  type = number
}

variable "instance_type" {
  type = string
}

output "app_asg" {
  value = aws_autoscaling_group.awsprod_app
}

output "app_backend_asg" {
  value = aws_autoscaling_group.awsprod_backend
}