variable "project_id" {
  type = string
}



variable "vpcs" {
  type = map(object({
    auto_create_subnetworks = bool

    firewalls = map(object({
      direction = string
      priority  = number
      ranges    = list(string)

      allow = list(object({
        protocol = string
        ports    = optional(list(string))
      }))



      target_tags = optional(list(string))
      #target_service_accounts = optional(list(string))
    }))

    subnets = map(object({
      cidr   = string
      region = string

      vms = map(object({
        machine_type        = string
        zone                = string
        public_ip           = bool
        startup_script_path = optional(string)
      }))
    }))
  }))
}

variable "nat_vpcs" {
  type = map(object({
    region = string
  }))
  default = {}
}

variable "vpc_peering" {
  type = map(object({
    vpc_1                = string
    vpc_2                = string
    export_custom_routes = optional(bool, false)
    import_custom_routes = optional(bool, false)
  }))
}

variable "classic_vpns" {
  type = map(object({
    vpc_1              = string
    vpc_2              = string
    shared_secret      = string
    region             = string
    vpc_1_subnet_cidrs = list(string)
    vpc_2_subnet_cidrs = list(string)
  }))

}

variable "static_routes" {
  type = map(object({
    vpc            = string
    dest_range     = string
    next_hop_type  = string
    next_hop_value = string
    priority       = number
    tag            = optional(list(string))
  }))
}

variable "uig" {
  type = map(object({
    zone      = string
    instances = list(string)
  }))
}

variable "http_lb" {
  type = map(object({
    instance_group = string
  }))

}


variable "internal_nlb" {
  type = map(object({
    vpc_key    = string
    subnet_key = string
    region     = string
    #uig_key = string
    port                   = list(string)
    health_port            = number
    target_tags            = list(string)
    ip_protocol            = string
    backend_instance_group = string
  }))
}


