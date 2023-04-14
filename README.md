# Deploy AWS 3-tier architecture using Terraform with S3 Remote Backend
![terraform_aws diagram](https://user-images.githubusercontent.com/53235392/231910493-a6f86686-95ea-4a07-8793-d3abb67ca6d5.png)

## Scenario:
 Design and create a highly available three-tier AWS architecture for web application and deploy using automation IAC Terraform with S3 Remote backend. User will access the application through the Internet, but the database mustn’t be accessible by the user.

### Overview:
 Three-tier architecture that includes a presentation tier (user interface), logic tire(application), and data tier(database) is the most implemented in terms of high scalability, security, data integrity, and performance. 

### Why Terraform?
 Terraform is one of the most popular open-source infrastructures as a code automation tool created by HashiCorp. It can manage infrastructure on multiple cloud platforms and supports human-readable configuration language, which helps write infrastructure code quickly and efficiently. Terraform's state allows tracking resource changes throughout your deployments.


### RemoteBackends
Remote backends enable storage of TerraForm state in a remote, location to enable secure collaboration.

In this project I use AWS S3 + Dynamo DB for remote Backend

### AWS 3 Tire Architecture:
•	VPC
•	EC2 instances
•	Elastic IP
•	Baston Host
•	Nat Gateway
•	Load balancer
•	Auto Scaling
•	RDS instance
•	Route 53 DNS Config
Prerequisites
AWS Account
AWS Access & Secret Key
Terraform installed on IDE (i.e Visual Studio Code)
SSH Agent (For Windows), AWS Installed on Terminal (For Mac)


## Deployment
### Steps
### 01.  	Run Terraform command
Step 0 terraform init
used to initialize a working directory containing Terraform configuration files
Step 1 terraform plan
used to create an execution plan
Step 2 terraform validate
validates the configuration files in a directory, referring only to the configuration and not accessing any remote services such as remote state, provider APIs, etc
Step 3 terraform apply
used to apply the changes required to reach the desired state of the configuration
Steps to initialize backend in AWS and manage it with Terraform:

### 02.	To use S3 bucket and dynamoDB table to be used as the state backend add this code 

backend "s3" {
bucket         = "terraform-bucket"  # s3 bucket name
 key            = "tf/terraform.tfstate"  # state file location
region         = "us-east-1"
dynamodb_table = "terraform-state-locking"
 encrypt        = true
 }
### 03 . Reinitialize with terraform init:


## Testing : 




