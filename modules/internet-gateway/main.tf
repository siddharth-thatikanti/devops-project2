resource "aws_internet_gateway" "project2IG" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}
