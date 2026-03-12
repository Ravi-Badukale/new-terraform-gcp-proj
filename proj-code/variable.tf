variable "project_id" {
}
variable "vpc_name" {
  
}

variable "subnetwork" {
    type = map(object({
      cidr_range = string
      region = string
    }))
  
}