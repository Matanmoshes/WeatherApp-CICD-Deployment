terraform {
    backend "s3" {
        bucket         = "terraform-backend-bucket-oioi1"    
        key            = "WeatherApp-CICD-Deployment/dev/terraform.tfstate"
        region         = "us-east-1"              
        dynamodb_table = "state_locking"  
        encrypt        = true                     
    }
}
