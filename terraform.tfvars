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
            startup_script_path = "./startup.sh"
          }
          app01 = {
            machine_type        = "e2-micro"
            zone                = "us-central1-a"
            public_ip           = false
            startup_script_path = "./startup.sh"
          }
          
          win01 = {
            machine_type = "e2-medium"
            zone         = "us-central1-a"
            public_ip    = true

            os_type                = "windows"
            startup_script_path    = "./iis.ps1"
            windows_admin_username = "adminuser"
            windows_admin_password = "StrongPassword123!"
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
            startup_script_path = "./startup.sh"
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



