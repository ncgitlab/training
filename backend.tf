terraform {
  backend "s3" {
    bucket = "awstesing-2020"
    key    = "terraformprd.tfstate"
    region = "us-east-1"
    secret_key =  "jhBvnhGj6iAwKQmP2g207lryHsDKKkyiZ3Llo200"
    access_key = "AKIA2SS2LBWLJDWDB6X5"
    dynamodb_table = "s3-backend-locking"
  }
}
