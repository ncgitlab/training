terraform {
  backend "s3" {
    bucket = "awstesing-2020"
    key    = "terraformprd.tfstate"
    region = "us-east-1"
    secret_key =  ""
    access_key = ""
    dynamodb_table = "s3-backend-locking"
  }
}
