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
        
        os_type = optional(string) 
        windows_admin_username = optional(string)
        windows_admin_password = optional(string)

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



