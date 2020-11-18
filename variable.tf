variable "access_key" {
     default = ""
}
variable "secret_key" {
     default = ""
}
variable "region" {
     default = "us-east-1"
}
variable "availabilityZone" {
     default = ["us-east-1a","us-east-1b"]
     type = list
}
variable "instanceTenancy" {
    default = "default"
}
variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}
variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}
variable "subnetCIDRblock" {
    default = ["10.0.1.0/24","10.0.2.0/24"]
    type = list
}
variable "destinationCIDRblock" {
    default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "egressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "mapPublicIP" {
    default = true
}
/*variable "tomcat_ami" {
    default = "ami-0e1cbd93e3eba6496"
}*/
variable "aws_instance_type" {
    default = "t2.micro"
}
variable "key_name" {
    default = "jenkins"
}
