variable "name" { type = string }
variable "launch_template_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "target_group_arn" { type = string }
variable "min_size" { type = number }
variable "desired_capacity" { type = number }
variable "max_size" { type = number }
variable "tags" {
  description = "adding the tage for the autoscaling"
  type        = map(string)
  default     = {}
}