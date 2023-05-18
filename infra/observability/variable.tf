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