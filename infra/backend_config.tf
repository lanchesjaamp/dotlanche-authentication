terraform {
  backend "s3" {
    key    = "states/dotlanche-authentication"
    region = "sa-east-1"
  }
}