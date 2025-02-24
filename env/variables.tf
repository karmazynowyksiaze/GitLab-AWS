variable "db_username" {
  description = "Database user account name"
  default = "gitlab"
}

variable "db_password" {
  description = "Database user account password"
}

variable "gitlab_domain" {
    description = "GitLab instance domain"
}

variable "instance_type" {
  description = "EC2 instance type for GitLab"
  default = "t3.medium"
}

variable "key_name" {
  description = "SSH key access to EC2 instance"
  
}