resource "google_compute_instance" "this" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  
  boot_disk {
    initialize_params {
      image = var.os_type == "windows" ? "projects/windows-cloud/global/images/family/windows-2022" : "projects/debian-cloud/global/images/family/debian-11"
    }
  }


  network_interface {
    subnetwork = var.subnet_self_link

    dynamic "access_config" {
      for_each = var.public_ip ? [1] : []
      content {}
    }
  }
  
  metadata = merge(
    var.startup_script_path == null ? {} : (
      var.os_type == "windows" ? {
        windows-startup-script-ps1 = file(var.startup_script_path)
      } : {
        startup-script = file(var.startup_script_path)
      }
    ),
    var.os_type == "windows" && var.windows_admin_username != null ? {
      windows-keys = jsonencode({
        userName = var.windows_admin_username
        password = var.windows_admin_password
      })
    } : {}
  )
}