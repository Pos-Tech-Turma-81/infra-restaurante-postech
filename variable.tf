variable "aws_region" {
  description = "Região onde os recursos serão criados"
  type        = string
  default     = "us-east-1" # pode mudar aqui
}

variable "regionDefault" {
  default = "us-east-1"
}

variable "projectName" {
  default = "EKS-FIAP"
}

<<<<<<< HEAD
=======
variable "labRole" {
  default = "arn:aws:iam::730335330366:role/LabRole"
}

>>>>>>> 6db79064dc768c84d08aa1cc301fe9bca37c3673
variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}

variable "nodeGroup" {
  default = "fiap"
}

variable "instanceType" {
  default = "t3.medium"
}

<<<<<<< HEAD
=======
variable "principalArn" {
  default = "arn:aws:iam::730335330366:role/voclabs"
}

>>>>>>> 6db79064dc768c84d08aa1cc301fe9bca37c3673
variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}
