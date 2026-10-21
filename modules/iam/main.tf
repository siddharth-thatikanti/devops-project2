data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "project2" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.project2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "project2profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.project2.name
}
