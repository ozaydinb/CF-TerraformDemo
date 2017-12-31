# CF-TerraformDemo
Azure Infrastructure as Code sample with Terraform script.

# Install Terraform

https://www.terraform.io/intro/getting-started/install.html

# Create Credentials

1- Install azure cli 1.0 https://docs.microsoft.com/en-us/azure/cli-install-nodejs 

2- Install jq (https://stedolan.github.io/jq/download/)

3- Download https://github.com/hashicorp/packer/blob/master/contrib/azure-setup.sh

4- Run "./azure-setup.sh setup" to create credentials.

# Run Terraform script

1- git clone

2- locate the directory and run "terraform init"

3- terraform plan (this command connect to azure with your credentials)

4- terraform apply (this command apply changes to azure if terraform plan was run successfuly)
