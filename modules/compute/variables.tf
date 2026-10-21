variable "name" { type = string }
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "instance_profile" { type = string }
variable "instance_sg_id" { type = string }
variable "tags" { type = map(string) }
