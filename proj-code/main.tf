module "project" {
    source = "/home/badukaleravi123/proj-code/module/provider"
    project_id = var.project_id
  
}

module "my_vpc" {
    source = "/home/badukaleravi123/proj-code/module/vpc"
    vpc_name = var.vpc_name
    subnetwork = var.subnetwork
    #region = var.region
}
