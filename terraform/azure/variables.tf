variable "region" {
  default = "westus2"
}

# vm
variable "vmUser" {
  default = "ubuntu"
}

# cloud-init
variable "timezone" {
  default = "UTC"
}

variable "traefikUser" {
}

variable "traefikPassword" {
}

variable "splunkProxyUser" {
  default = "splunk"
}

variable "splunkProxyPassword" {
}

variable "splunkAdminPassword" {
}
