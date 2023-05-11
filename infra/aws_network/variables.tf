variable "project_name" {
  description = "A prefix for names of objects created by this module"
  default     = "st"
}

variable "region" {
  description = "Region where the instance is created"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone where the instance is created"
  type        = string
}