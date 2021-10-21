variable "image" {
  type = string
  description = "The Google compute image to build the Aviatrix Controller"
  default = ""
}

variable "network" {
  type = string
  description = ""
  default = ""
}

variable "subnetwork" {
  type = string
  description = "The subnetwork to attach the Aviatrix Controller"
  default = ""
}

variable "subnet_cidr" {
  type = string
  description = "The cidr for the subnetwork this module will create or an existing subnet"
  default = "10.128.0.0/9"
}

variable incoming_ssl_cidrs {
  type = list(string)
  description = "The CIDRs to be allowed for HTTPS(port 443) access to the Aviatrix Controller"
}

variable "public_ip" {
  type = string
  description = "The public IP address to assign to the controller"
  default = ""
}

variable "controller_name" {
  type = string
  description = "The Aviatrix Controller name"
  default = "aviatrix-controller"
}

variable "service_account_email" {
  type = string
  description = "The Service Account to assign to the Aviatrix Controller"
  default = ""
}

variable "service_account_scopes" {
  type = list(string)
  description = "The scopes to assign to the Aviatrix Controller's Service Account"
  default = ["cloud-platform"]
}

variable "controller_machine_type" {
  type = string
  description = "The machine type to create the Aviatrix Controller"
  default = "e2-standard-2"
}