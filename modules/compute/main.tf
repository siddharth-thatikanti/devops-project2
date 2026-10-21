resource "aws_launch_template" "project2-lt" {
  name_prefix   = "${var.name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile { name = var.instance_profile }
  vpc_security_group_ids = [var.instance_sg_id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y nginx
    echo '<html><body><h1>It works! Provisioned by Terraform Auto Scaling.</h1></body></html>' > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.name}-instance" })
  }
}
