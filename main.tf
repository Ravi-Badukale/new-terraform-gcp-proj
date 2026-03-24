module "vpc" {
  for_each = var.vpcs
  source   = "./modules/vpc"

  name                    = each.key
  auto_create_subnetworks = each.value.auto_create_subnetworks
}

module "subnet" {
  for_each = {
    for vpc_subnet in flatten([
      for vpc_name, vpc in var.vpcs : [
        for subnet_name, subnet in vpc.subnets : {
          key      = "${vpc_name}-${subnet_name}"
          vpc_name = vpc_name
          subnet   = subnet
        }
      ]
    ]) : vpc_subnet.key => vpc_subnet
  }
  source        = "./modules/subnet"
  vpc_self_link = module.vpc[each.value.vpc_name].self_link
  name          = each.key
  cidr          = each.value.subnet.cidr
  region        = each.value.subnet.region
}

module "compute" {
  for_each = {
    for vm_item in flatten([
      for vpc_name, vpc in var.vpcs : [
        for subnet_name, subnet in vpc.subnets : [
          for vm_name, vm in subnet.vms : {
            key                 = "${vpc_name}-${subnet_name}-${vm_name}"
            vm                  = vm
            subnet_key          = "${vpc_name}-${subnet_name}"
            public_ip           = vm.public_ip
            
            startup_script_path        = lookup(vm, "startup_script_path", null)
            os_type                    = lookup(vm, "os_type", "linux")
            windows_admin_username     = lookup(vm, "windows_admin_username", null)
            windows_admin_password     = lookup(vm, "windows_admin_password", null)

          }
        ]
      ]
    ]) : vm_item.key => vm_item
  }

  source              = "./modules/compute"
  name                = each.key
  machine_type        = each.value.vm.machine_type
  zone                = each.value.vm.zone
  public_ip           = each.value.public_ip
  startup_script_path = each.value.startup_script_path
  subnet_self_link    = module.subnet[each.value.subnet_key].self_link
  
  os_type                 = each.value.os_type
  windows_admin_username  = each.value.windows_admin_username
  windows_admin_password  = each.value.windows_admin_password

}

module "firewall" {
  for_each = {
    for fw_item in flatten([
      for vpc_name, vpc in var.vpcs : [
        for fw_name, fw in vpc.firewalls : {
          key         = "${vpc_name}-${fw_name}"
          vpc_name    = vpc_name
          name        = fw_name
          direction   = fw.direction
          priority    = fw.priority
          ranges      = fw.ranges
          allow       = fw.allow
          deny        = lookup(fw, "deny", [])
          target_tags = lookup(fw, "target_tags", [])

        }
      ]
    ]) : fw_item.key => fw_item
  }

  source = "./modules/firewall"

  name              = each.key
  network_self_link = module.vpc[each.value.vpc_name].self_link
  direction         = each.value.direction
  priority          = each.value.priority
  ranges            = each.value.ranges
  allow             = each.value.allow
  #deny                 = each.value.deny
  target_tags = each.value.target_tags
  #target_service_accounts = each.value.target_service_accounts
}

module "nat" {
  for_each = var.nat_vpcs

  source            = "./modules/nat"
  vpc_name          = each.key
  region            = each.value.region
  network_self_link = module.vpc[each.key].self_link
}

