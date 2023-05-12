variable "docker_hosts" {
  description = "List of names of docker host servers to scrape node metrics from"
  type        = list(string)
}