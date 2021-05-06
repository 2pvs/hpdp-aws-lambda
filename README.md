#High Performance Data Processing Tool

##Description
This solution is dedicated to parallel data processing on AWS platform: Lambda, S3, SQS, CloudWatch. It loads objects from S3, processes them in parallel and returns results back to S3. Current sample solution converts TIFF files to JPEGs. In order to do other data processing create custom Worker Lambda function.

##Installation
Installation works on Linux. If you need to run installation from Windows, use Terraform for Windows and rewrite build.sh for PS1.

###Prerequisites
•	Open AWS account and issue AWS access keys with admin privileges
•	Install AWS CLI. 
•	Find a free region in your aws account and configure cli profile with admin keys

###Deployment
1.	Copy solution code to your computer
2.	Download or build Terraform for Linux
3.	Edit file *tf/variables.tf*
    a.	variable "aws_default_region" { default = "you aws region code (like us-east-1)" }
    b.	variable "aws_cli_profile"    { default = "put your aws profile name" }
    c.	variable "s3_bucket"          { default = "put a global unique name for your s3 bucket here"}
4.	Navigate to /tf folder
5.	Run **terraform init**
6.	Run **terraform apply**
7.  Open *build.sh* and edit AWS_PROFILE and AWS_REGION variables accoding to step 3
7.	Navigate to solution root folder and run **sh build.sh**

##Solution usage
•	Prepare your data files and copy them to S3 bucket defined in tf/variables.tf  *variable "s3_bucket"* to a dedicated folder. In our sample case the data must be TIFF files.
•	Create empty file job.start and copy it to the root of the data folder.
•	Check results folder for processing results.

##Credits
Created by Vladimir Popov, https://www.linkedin.com/in/vpopov
Email: vlad@2pvs.com

##License
MIT License