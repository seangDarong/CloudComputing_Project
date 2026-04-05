variable "region"{
    description = "AWS region for deploying everything in"
    type = string
    default = "ap-southeast-1"
}

variable "project_name"{
    description = "name prefix for all resources"
    type = string
    default = "cloud-computing-project"
}

variable "vpc_cidr" {
    description = "IP range for the VPC"
    type = string
    default = "10.0.0.0/16" # /16 means 65,536 available IP addresses
}

variable "instance_type" {
    description = "EC2 instance size"
    type = string
    default = "t3_micro"
    # t3.micro = small, cheap, good for student projects
}

variable "ami_id" {
    description = "Amazon Linux 2 AMI for ap-southeast-1"
    type        = string
    default     = "ami-0df7a207adb9748c7"
    # This is Amazon Linux 2 in Singapore region
}

variable "asg_min_size" {
    description = "Minimum number of EC2 instances"
    type        = number
    default     = 1
    # Always keep at least 1 server running
}

variable "asg_max_size" {
    description = "Maximum number of EC2 instances"
    type        = number
    default     = 3
    # Never go above 3 servers
}

variable "asg_desired_capacity" {
    description = "Normal number of EC2 instances"
    type        = number
    default     = 2
    # Normally run 2 servers
}


# ── Database
variable "db_name" {
    description = "Name of the MySQL database"
    type        = string
    default     = "studentdb"
}

variable "db_username" {
    description = "Database admin username"
    type        = string
    default     = "admin"
}

variable "db_password" {
    description = "Database admin password"
    type        = string
    sensitive   = true
    # sensitive = true means Terraform hides
    # this value in logs and terminal output
    # NO default - you must provide this!
}

variable "db_instance_class" {
    description = "RDS instance size"
    type        = string
    default     = "db.t3.micro"
}

# ── S3
variable "s3_bucket_name" {
    description = "S3 bucket name for student photos"
    type        = string
    default     = "student-project-photos-2024"
    # S3 bucket names must be globally unique!
    # Change this to something unique
}

# ── GitHub
variable "github_repo" {
    description = "GitHub repo URL to clone on EC2"
    type        = string
    default     = "https://github.com/seangDarong/CloudComputing_Project.git"
    # Change this to your actual GitHub repo URL
}