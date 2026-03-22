module "vpc" {
  for_each = var.vpcs
  source   = "/home/badukaleravi123/proj-terraform-handled-proj/modules/vpc"

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
  source        = "/home/badukaleravi123/proj-terraform-handled-proj/modules/subnet"
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
            startup_script_path = lookup(vm, "startup_script_path", null)
          }
        ]
      ]
    ]) : vm_item.key => vm_item
  }

  source              = "/home/badukaleravi123/proj-terraform-handled-proj/modules/compute"
  name                = each.key
  machine_type        = each.value.vm.machine_type
  zone                = each.value.vm.zone
  public_ip           = each.value.public_ip
  startup_script_path = each.value.startup_script_path
  subnet_self_link    = module.subnet[each.value.subnet_key].self_link
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

  source = "/home/badukaleravi123/proj-terraform-handled-proj/modules/firewall"

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

  source            = "/home/badukaleravi123/proj-terraform-handled-proj/modules/nat"
  vpc_name          = each.key
  region            = each.value.region
  network_self_link = module.vpc[each.key].self_link
}

module "vpc-peering" {
  for_each = {
    for vpc_peering in flatten([
      for name, p in var.vpc_peering : [
        {
          key     = "${name}-a-to-b"
          name    = "${p.vpc_1}-to-${p.vpc_2}"
          network = p.vpc_1
          peer    = p.vpc_2
          export  = lookup(p, "export_custom_routes", false)
          import  = lookup(p, "import_custom_routes", false)
        },
        {
          key     = "${name}-b-to-a"
          name    = "${p.vpc_2}-to-${p.vpc_1}"
          network = p.vpc_2
          peer    = p.vpc_1
          export  = lookup(p, "export_custom_routes", false)
          import  = lookup(p, "import_custom_routes", false)
        }
      ]
    ]) : vpc_peering.key => vpc_peering
  }

  source = "/home/badukaleravi123/proj-terraform-handled-proj/modules/vpc-peering"

  name                   = each.value.name
  network_self_link      = module.vpc[each.value.network].self_link
  peer_network_self_link = module.vpc[each.value.peer].self_link

  export_custom_routes = each.value.export
  import_custom_routes = each.value.import

}

module "classic_vpns" {
  for_each = var.classic_vpns
  source   = "/home/badukaleravi123/proj-terraform-handled-proj/modules/classic-vpn"

  name                   = each.key
  region                 = each.value.region
  network_self_link      = module.vpc[each.value.vpc_1].self_link
  peer_network_self_link = module.vpc[each.value.vpc_2].self_link

  shared_secret       = each.value.shared_secret
  local_subnet_cidrs  = each.value.vpc_1_subnet_cidrs
  remote_subnet_cidrs = each.value.vpc_2_subnet_cidrs
}

module "static_routes" {
  source = "/home/badukaleravi123/proj-terraform-handled-proj/modules/static_route"

  routes = {
    for route_name, route in var.static_routes :
    route_name => {
      network_self_link = module.vpc[route.vpc].self_link
      dest_range        = route.dest_range
      next_hop_type     = route.next_hop_type
      next_hop_value    = route.next_hop_value
      priority          = route.priority
      tag               = lookup(route, "tag", null)
    }
  }
}

module "uig" {
  source = "/home/badukaleravi123/proj-terraform-handled-proj/modules/instance-group"

  for_each = var.uig
  name     = each.key
  zone     = each.value.zone

  instances = [
    for vm_name in each.value.instances :
    module.compute[vm_name].self_link
  ]
}

module "http_lb" {
  source = "/home/badukaleravi123/proj-terraform-handled-proj/modules/http-lb"

  for_each = var.http_lb
  name     = each.key

  backend_instance_group = module.uig[each.value.instance_group].self_link
}

module "internal_nlb" {
  for_each = var.internal_nlb
  source   = "/home/badukaleravi123/proj-terraform-handled-proj/modules/internal_nlb"

  name       = each.key
  region     = each.value.region
  network    = module.vpc[each.value.vpc_key].self_link
  subnetwork = module.subnet[each.value.subnet_key].self_link

  ports                  = each.value.port
  health_check_port      = each.value.health_port
  ip_protocol            = each.value.ip_protocol
  backend_instance_group = module.uig[each.value.backend_instance_group].self_link
}
