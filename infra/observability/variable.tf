variable "docker_hosts" {
  description = "List of names of docker host servers to scrape node metrics from"
  type        = list(string)
}

variable "node_label_name" {
  description = "The node label to use to use for observability stack"
  type        = string
}

variable "node_label_value" {
  description = "The node label value to use to use for observability stack"
  type        = string
}

variable "node_toleration" {
  description = "The toleration to use for the observability stack"
  type        = string
}

variable "aws_managed_prometheus_workspace" {
  description = "The name of the AWS Managed prometheus workspace for this test."
  type        = string
  nullable    = false
}

variable "aws_managed_prometheus_region" {
  description = "The region of the AWS Managed prometheus workspace for this test."
  type    = string
}