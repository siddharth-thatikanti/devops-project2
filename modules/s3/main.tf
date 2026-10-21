data "aws_region" "current" {}
resource "aws_s3_bucket" "project198" {
  bucket = var.bucket_name
  tags   = merge(var.tags, { Name = "${var.name}-bucket" })
}
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.project198.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.project198.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids
  tags              = merge(var.tags, { Name = "${var.name}-s3-endpoint" })
}
