variable "ami" {
    default = "ami-053b0d53c279acc90" #"ami-0f8e81a3da6e2510a"  
}
variable "instance-type" {
    default = "t2.medium"  
}
variable "region" {
    default = "us-east-1"  
}
variable "cidr" {
    default = "10.1.0.0/16"  
}
variable "subnet-cidr" {
    default = "10.1.0.0/24"  
}
variable "instance-master" {
    default = "k8s-master"  
}
variable "instance-worker" {
    default = "k8s-worker"  
}