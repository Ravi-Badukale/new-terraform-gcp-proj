module "project_id" {
    source = "./proj-code/module/provider"
    project = var.project_id
  
}

module "my_vpc" {
    source = "./proj-code/module/vpc"
    vpc_name = var.vpc_name
    subnetwork = var.subnetwork
    region = var.region
}