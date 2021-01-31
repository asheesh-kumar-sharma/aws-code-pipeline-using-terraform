terraform {
  backend "s3"{
     bucket = "ci-cd-terraform-state-bucket-virtega"
     key    = "terraform.tfstate"
     region = "us-east-1"
     dynamodb_table = "terraform-state-locks"
   
  }
}