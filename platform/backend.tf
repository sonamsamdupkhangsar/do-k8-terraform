terraform {
  backend "s3" {
    bucket = "sonam"
    key    = "terraform/terraform.tfstate"
    endpoint = "https://sfo2.digitaloceanspaces.com" # Replace with your Space's region endpoint
    region = "us-east-1" # The region value is technically ignored by DO but required by the s3 backend
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    # Authentication will be handled via environment variables
  }
}

#Run terraform init to initialize the backend and configure Terraform to use the S3 backend for state management.
#Use the standard AWS environment variables, as the S3 backend looks for these:
#export AWS_ACCESS_KEY_ID="your_spaces_access_key"
#export AWS_SECRET_ACCESS_KEY="your_spaces_secret_key"
