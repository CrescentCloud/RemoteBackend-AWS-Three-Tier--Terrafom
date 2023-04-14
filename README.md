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
•	 &nbsp;VPC<br>
•	 &nbsp;EC2 instances<br>
•	 &nbsp;Elastic IP<br>
•	 &nbsp;Baston Host<br>
•	 &nbsp;Nat Gateway<br>
•	 &nbsp;Load balancer<br>
•	 &nbsp;Auto Scaling<br>
•	 &nbsp;RDS instance<br>
•	 &nbsp;Route 53 DNS Config<br>
### Prerequisites
--> AWS Account<br>
--> AWS Access & Secret Key<br>
--> Terraform installed on IDE (i.e Visual Studio Code)<br>
--> SSH Agent (For Windows), AWS Installed on Terminal (For Mac)<br>
--> MySql Workbech for Database connection testing


## Deployment
### Steps 
### 01.  	Run Terraform command
Step 0 used to initialize a working directory containing Terraform configuration files
~~~
terraform init
~~~

Step 1 used to create an execution plan
~~~
terraform plan
~~~

Step 2 validates the configuration files in a directory, referring only to the configuration and not accessing any remote services such as remote state, provider APIs, etc
~~~
terraform validate
~~~

Step 3 used to apply the changes required to reach the desired state of the configuration
Steps to initialize backend in AWS and manage it with Terraform:
~~~
terraform apply
~~~


### 02.	To use S3 bucket and dynamoDB table to be used as the state backend add this code

~~~
backend "s3" {
bucket         = "terraform-bucket"  # s3 bucket name
 key            = "tf/terraform.tfstate"  # state file location
region         = "us-east-1"
dynamodb_table = "terraform-state-locking"
 encrypt        = true
 }
~~~
 
### 03 . Reinitialize with 
~~~ 
terraform init 
~~~


## Testing : 

## Troubleshooting :
if Reinitialize failed 
<img width="669" alt="Screen Shot 2023-04-14 at 12 12 11 AM" src="https://user-images.githubusercontent.com/53235392/231961739-56edf8c9-6d7b-4ed0-80da-8ea371cbfb1c.png">
run bellow code
~~~
terraform init -backend-config="access_key=<your_AWS_access_key>" -backend-config="secret_key=<your_AWS_secret_key>" -backend-config="region=us-east-1"
~~~



