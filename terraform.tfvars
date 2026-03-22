project_id = "terraform-handled-proj"
#region     = "us-central1"

vpcs = {
  vpc-1 = {
    auto_create_subnetworks = false

    subnets = {
      subnet-a = {
        cidr   = "10.0.1.0/24"
        region = "us-central1"

        vms = {
          web01 = {
            machine_type        = "e2-medium"
            zone                = "us-central1-a"
            public_ip           = false
            startup_script_path = "/home/badukaleravi123/proj-terraform-handled-proj/startup.sh"
          }
          app01 = {
            machine_type        = "e2-micro"
            zone                = "us-central1-a"
            public_ip           = false
            startup_script_path = "/home/badukaleravi123/proj-terraform-handled-proj/startup.sh"
          }
        }
      }

      subnet-b = {
        cidr   = "10.0.2.0/24"
        region = "us-west1"

        vms = {
          web02 = {
            machine_type        = "e2-medium"
            zone                = "us-west1-a"
            public_ip           = false
            startup_script_path = "/home/badukaleravi123/proj-terraform-handled-proj/startup.sh"
          }
        }

      }
    }


    firewalls = {
      allow-ssh = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["35.235.240.0/20"]

        allow = [
          {
            protocol = "tcp"
            ports    = ["22"]
          }
        ]

        target_tags = []
      }

      allow-http = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["10.0.1.0/24", "10.0.2.0/24", "172.16.1.0/24", "192.168.1.0/24"]

        allow = [
          {
            protocol = "tcp"
            ports    = ["80", "443"]
          }
        ]

        target_tags = []
      }
      allow-hc = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]

        allow = [
          {
            protocol = "tcp"
            ports    = ["80", "443"]
          }
        ]

        target_tags = []
      }

    }


  }

  vpc-2 = {
    auto_create_subnetworks = false

    subnets = {
      subnet-dev = {
        cidr   = "172.16.1.0/24"
        region = "us-central1"

        vms = {
          web03 = {
            machine_type = "e2-micro"
            zone         = "us-central1-a"
            public_ip    = false
          }
          public-vm = {
            machine_type = "e2-medium"
            zone         = "us-central1-a"
            public_ip    = true

          }
        }
      }
    }
    firewalls = {
      allow-ssh = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["35.235.240.0/20"]

        allow = [
          {
            protocol = "tcp"
            ports    = ["22"]
          }
        ]

        target_tags = []
      }

      allow-http = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["10.0.1.0/24", "10.0.2.0/24", "172.16.1.0/24"]

        allow = [
          {
            protocol = "tcp"
            ports    = ["80", "443"]
          }
        ]

        target_tags = []
      }
    }
  }
  vpc-3 = {
    auto_create_subnetworks = false
    subnets = {
      subnet-dev = {
        cidr   = "192.168.1.0/24"
        region = "us-central1"

        vms = {
          web04 = {
            machine_type = "e2-micro"
            zone         = "us-central1-a"
            public_ip    = false
          }
        }
      }
    }
    firewalls = {
      allow-ssh = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["35.235.240.0/20"]

        allow = [
          {
            protocol = "tcp"
            ports    = ["22"]
          }
        ]

        target_tags = []
      }
      allow-http = {
        direction = "INGRESS"
        priority  = 1000
        ranges    = ["10.0.1.0/24", "192.168.1.0/24"]

        allow = [
          {
            protocol = "tcp"
            ports    = ["80", "443"]
          }
        ]

        target_tags = []
      }
    }
  }
}

nat_vpcs = {
  vpc-1 = {
    region = "us-central1"
  }
}

vpc_peering = {
  "vpc1-to-vpc2" = {
    vpc_1                = "vpc-1"
    vpc_2                = "vpc-2"
    export_custom_routes = true
    import_custom_routes = true
  }
  "vpc2-to-vpc1" = {
    vpc_1                = "vpc-2"
    vpc_2                = "vpc-1"
    export_custom_routes = true
    import_custom_routes = true
  }
}

classic_vpns = {
  vpc1-to-vpc3 = {
    vpc_1  = "vpc-1"
    vpc_2  = "vpc-3"
    region = "us-central1"

    shared_secret = "badukaleravi123"

    vpc_1_subnet_cidrs = ["10.0.1.0/24"]
    vpc_2_subnet_cidrs = ["192.168.1.0/24"]
  }

}

static_routes = {
  "vpc1-to-vpc3-route" = {
    vpc           = "vpc-1"
    dest_range    = "192.168.1.0/24"
    next_hop_type = "vpn_tunnel"

    next_hop_value = "vpc1-to-vpc3-tunnel1"

    priority = 500
  }

  vpc3-to-vpc1-route = {
    vpc           = "vpc-3"
    dest_range    = "10.0.1.0/24"
    next_hop_type = "vpn_tunnel"

    next_hop_value = "vpc1-to-vpc3-tunnel2"


    priority = 500
  }
}

uig = {
  web-uig = {
    zone      = "us-central1-a"
    instances = ["vpc-1-subnet-a-web01"]
  }

  app-uig = {
    zone      = "us-central1-a"
    instances = ["vpc-1-subnet-a-app01"]
  }
}

http_lb = {
  "web-lb" = {
    instance_group = "web-uig"

  }
}

internal_nlb = {
  ilb-app = {
    vpc_key    = "vpc-1"
    subnet_key = "vpc-1-subnet-a"
    region     = "us-central1"
    #uig_key = "app-uig"
    port                   = ["80"]
    health_port            = 80
    target_tags            = []
    ip_protocol            = "TCP"
    backend_instance_group = "app-uig"
  }
}

