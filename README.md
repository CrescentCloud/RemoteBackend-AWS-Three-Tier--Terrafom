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
<img width="591" alt="Screen Shot 2023-04-14 at 12 11 02 AM" src="https://user-images.githubusercontent.com/53235392/231965853-ed041d00-1124-4236-9f84-d48f5ce0472e.png">

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

## Troubleshooting :
if Reinitialize failed<br> 
<img width="669" alt="Screen Shot 2023-04-14 at 12 12 11 AM" src="https://user-images.githubusercontent.com/53235392/231961739-56edf8c9-6d7b-4ed0-80da-8ea371cbfb1c.png">
<br>run bellow code
~~~
terraform init -backend-config="access_key=<your_AWS_access_key>" -backend-config="secret_key=<your_AWS_secret_key>" -backend-config="region=us-east-1"
~~~

## Testing : 
On the AWS console, the following item should be available: VPC, subnets, IGW, EC2 instances, load balancers, autoscaling, RDS database, route 53, and S3 bucket with inside terraform state file<br>
#### S3
<img width="505" alt="Screen Shot 2023-04-14 at 1 05 57 AM" src="https://user-images.githubusercontent.com/53235392/231969401-98b3c88d-7e9d-4759-9ff3-91589a98a3da.png">
<img width="882" alt="Screen Shot 2023-04-14 at 12 22 30 AM" src="https://user-images.githubusercontent.com/53235392/231970455-24a23364-cdbe-46b1-8aba-b1a10c6ec623.png">

#### VPC
<img width="891" alt="Screen Shot 2023-04-14 at 12 19 30 AM" src="https://user-images.githubusercontent.com/53235392/231971534-79f2a218-8c0f-4cc6-b1ba-2dee980247ac.png">

#### subnet

<img width="759" alt="Screen Shot 2023-04-14 at 12 47 50 AM" src="https://user-images.githubusercontent.com/53235392/231972049-26eadb0b-6bd2-4381-baec-6a8a464af8bc.png">

#### loadbalancer
<img width="920" alt="Screen Shot 2023-04-14 at 12 20 40 AM" src="https://user-images.githubusercontent.com/53235392/231976108-dccee17d-65c3-4279-98e4-759e4ec9c226.png">

#### RDS

<img width="801" alt="Screen Shot 2023-04-14 at 12 25 50 AM" src="https://user-images.githubusercontent.com/53235392/231972378-c0628314-6c78-45a3-a6b7-1c81dc1902cd.png">

#### Route 53-> Hosted Zone


<img width="581" alt="Screen Shot 2023-04-14 at 1 30 43 AM" src="https://user-images.githubusercontent.com/53235392/231974555-13664924-2d7e-49aa-af85-def9aa496d6e.png">
<img width="840" alt="Screen Shot 2023-04-14 at 12 23 39 AM" src="https://user-images.githubusercontent.com/53235392/231975589-61e989d3-d644-417e-8fb9-3edb4c96fc3d.png">

#### SSH to Bastion Host
<img width="400" alt="Screen Shot 2023-04-14 at 2 17 35 AM" src="https://user-images.githubusercontent.com/53235392/231986940-ca08d6d9-4e13-4949-a83d-17ec20575717.png">

#### Connect Application server using private IP
<img width="500" alt="Screen Shot 2023-04-14 at 2 27 20 AM" src="https://user-images.githubusercontent.com/53235392/231988981-00495783-26ef-41ce-9982-11325dbdafdd.png">

