variable "db_name" {
  type      = string
  sensitive = true
}

variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}

variable "db_fqdn" {
  default = "db.wordpress.ael"
}

variable "nfs_fqdn" {
  default = "nfs.wordpress.ael"
}
