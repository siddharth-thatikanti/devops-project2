variable "name" { type = string }
variable "bucket_name" {
  type = string
  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63 && !strcontains(var.bucket_name, "replace-with")
    error_message = "Set s3_bucket_name to a globally unique S3 bucket name."
  }
}
variable "vpc_id" { type = string }
variable "route_table_ids" { type = list(string) }
variable "tags" { type = map(string) }
