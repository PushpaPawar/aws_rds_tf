terraform {
     backend "s3" {
        bucket = "talent-academy-pushpa-labs-tfstates"
        key = "talent-academy/aws_rds/terraform.tfstates"
        region = "eu-west-1"
     }
}



