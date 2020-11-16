terraform {
  backend "s3" {
    bucket = "awstesing-2020"
    key    = "terraformtest.tfstate"
    region = "us-east-1"
    secret_key =  "K1/Zpxq/i+TJwydOQjuctMgAzDERZFu9ZpINFiv2"
    access_key = "AKIA2SS2LBWLGOWBTQOK"
    dynamodb_table = "s3-backend-locking"
  }
}
