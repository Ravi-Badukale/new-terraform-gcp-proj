project_id  = "project-d0c8f26d-742f-448d-9aa"

vpc_name = "terraform-vpc"

subnetwork = {
    subnet-1 = {
        cidr_range = "10.0.1.0/24"
        region = "us-central1"
    }
    subnet-2 = {
        cidr_range = "10.0.2.0/24"
        region = "us-west1"
    }
}
