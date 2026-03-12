resource "google_compute_network" "my_vpc" {
    name = var.vpc_name
    auto_create_subnetworks = false
    routing_mode = "GLOBAL"
    mtu = 1460
    
  }

resource "google_compute_subnetwork" "subnetwork" {
    for_each = var.subnetwork
    name = each.key
    network = google_compute_network.my_vpc.id
    ip_cidr_range = each.value.cidr_range
    region = each.value.region
}
  
