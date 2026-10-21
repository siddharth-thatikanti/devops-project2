terraform {
  backend "s3" {
    bucket       = "siddhartha-terraform-state-2026"
    key          = "dev/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}