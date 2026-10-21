resource "aws_eip" "project2" {
  count  = length(var.public_subnet_ids)
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name}-nat-eip-${count.index + 1}" })
}
resource "aws_nat_gateway" "this" {
  count         = length(var.public_subnet_ids)
  allocation_id = aws_eip.project2[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]
  tags          = merge(var.tags, { Name = "${var.name}-nat-${count.index + 1}" })
}
