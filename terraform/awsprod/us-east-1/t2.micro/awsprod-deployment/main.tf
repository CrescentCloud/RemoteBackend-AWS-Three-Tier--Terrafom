# --- root/main.tf ---
terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  backend "s3" {
  bucket         = "crescent-tfxy-state" # REPLACE WITH YOUR BUCKET NAME
  key            = "import-bootstrap/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-locking"
  encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.63.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
   secret_key = "lW3fdsPhQduYjP8jNcvCPohbc0SVJU9aoVI0NrkM"
  access_key = "AKIAWUMVPP422O244UPA"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "crescent-tfxy-state" # REPLACE WITH YOUR BUCKET NAME
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}





/* provider "aws" {
  region = local.location
  secret_key = "lW3fdsPhQduYjP8jNcvCPohbc0SVJU9aoVI0NrkM"
  access_key = "AKIAWUMVPP422O244UPA"
}*/

locals {
  cwd           = reverse(split("/", path.cwd))
  instance_type = local.cwd[1]
  location      = local.cwd[2]
  environment   = local.cwd[3]
  vpc_cidr      = "10.1.0.0/16"
}


module "resources" {
  source            = "../../../../../resources"
  vpc_cidr          = local.vpc_cidr
  access_ip         = var.access_ip
  public_sn_count   = 2
  private_sn_count  = 2
  db_subnet_group   = true
  availabilityzone  = "us-east-1a"
  azs               = 2
  frontend_app_sg         = module.resources.frontend_app_sg
  backend_app_sg          = module.resources.backend_app_sg
  bastionhost_sg          = module.resources.bastionhost_sg
  public_subnets          = module.resources.public_subnets
  private_subnets         = module.resources.private_subnets
  bastionhost_instance_count  = 1
  instance_type           = local.instance_type
  key_name                = "AwsProdKeyPair"
  lb_tg_name              = module.resources.lb_tg_name
  lb_tg                   = module.resources.lb_tg

  db_storage           = 10
  db_engine_version    = "8.0.32"
  db_instance_class    = "db.t2.micro"
  db_name              = var.db_name
  dbuser               = var.dbuser
  dbpassword           = var.dbpassword
  db_identifier        = "awsprod-db"
  skip_db_snapshot     = true
  rds_sg               = module.resources.rds_sg
  db_subnet_group_name = module.resources.db_subnet_group_name[0]

  lb_sg                   = module.resources.lb_sg
  # public_subnets          = module.resources.public_subnets
  tg_port                 = 80
  tg_protocol             = "HTTP"
  vpc_id                  = module.resources.vpc_id
  app_asg                 = module.resources.app_asg
  listener_port           = 80
  listener_protocol       = "HTTP"
  # azs                     = 2

} 

