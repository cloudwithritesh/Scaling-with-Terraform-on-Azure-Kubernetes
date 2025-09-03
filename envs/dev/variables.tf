variable "name" {
  description = "Base name/prefix for resources"
  type        = string
  default     = "tf-aks-demo"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "kubernetes_version" {
  description = "AKS version"
  type        = string
  default     = "1.29.7"
}

variable "system_node_count" {
  description = "System node pool count"
  type        = number
  default     = 1
}

variable "user_node_min" {
  description = "Min nodes in user pool (autoscaler)"
  type        = number
  default     = 0
}

variable "user_node_max" {
  description = "Max nodes in user pool (autoscaler)"
  type        = number
  default     = 3
}

variable "address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Subnet prefixes"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.0.0.10"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.0.0.0/24"
}
