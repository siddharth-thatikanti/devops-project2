locals {
  common_tags = merge(var.tags, { Project = var.project_name })
}
module "vpc" {
  source     = "./modules/vpc"
  name       = var.project_name
  cidr_block = var.vpc_cidr
  tags       = local.common_tags
}
module "subnets" {
  source               = "./modules/subnets"
  name                 = var.project_name
  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}
module "internet_gateway" {
  source = "./modules/internet-gateway"
  name   = var.project_name
  vpc_id = module.vpc.vpc_id
  tags   = local.common_tags
}
module "nat_gateway" {
  source            = "./modules/nat-gateway"
  name              = var.project_name
  public_subnet_ids = module.subnets.public_subnet_ids
  tags              = local.common_tags
}
module "route_tables" {
  source              = "./modules/route-tables"
  name                = var.project_name
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  nat_gateway_ids     = module.nat_gateway.nat_gateway_ids
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
  tags                = local.common_tags
}
module "security_groups" {
  source            = "./modules/security-groups"
  name              = var.project_name
  vpc_id            = module.vpc.vpc_id
  allowed_http_cidr = var.allowed_http_cidr
  tags              = local.common_tags
}
module "iam" {
  source = "./modules/iam"
  name   = var.project_name
  tags   = local.common_tags
}
module "s3" {
  source          = "./modules/s3"
  name            = var.project_name
  bucket_name     = var.s3_bucket_name
  vpc_id          = module.vpc.vpc_id
  route_table_ids = concat([module.route_tables.public_route_table_id], module.route_tables.private_route_table_ids)
  tags            = local.common_tags
}
module "load_balancer" {
  source            = "./modules/load-balancer"
  name              = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  tags              = local.common_tags
}
module "compute" {
  source           = "./modules/compute"
  name             = var.project_name
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  instance_profile = module.iam.instance_profile_name
  instance_sg_id   = module.security_groups.instance_sg_id
  tags             = local.common_tags
}
module "autoscaling" {
  source             = "./modules/autoscaling"
  name               = var.project_name
  launch_template_id = module.compute.launch_template_id
  private_subnet_ids = module.subnets.private_subnet_ids
  target_group_arn   = module.load_balancer.target_group_arn
  min_size           = var.min_size
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  tags               = local.common_tags
}
output "alb_dns_name" { value = module.load_balancer.alb_dns_name }
output "s3_bucket_name" { value = module.s3.bucket_name }
output "vpc_id" { value = module.vpc.vpc_id }
