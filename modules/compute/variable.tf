variable "name" {}
variable "machine_type" {}
variable "zone" {}
variable "subnet_self_link" {}

variable "public_ip" {
  type    = bool
  default = true
}

variable "startup_script_path" {
  type    = string
  default = null
}


variable "os_type" {
  type    = string
  default = "linux" # linux | windows
}

variable "windows_admin_username" {
  type    = string
  default = null
}

variable "windows_admin_password" {
  type    = string
  default = null
}
