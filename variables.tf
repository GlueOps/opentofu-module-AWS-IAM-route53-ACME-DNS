variable "hosted_zone_id" {
  description = "The Route53 Hosted Zone ID where ACME DNS-01 challenge records will be created"
  type        = string
}

variable "cert_domains" {
  description = "List of domains/subdomains requiring certificates (e.g., [\"*.example.com\", \"auth.example.com\"])"
  type        = list(string)

  validation {
    condition     = length(var.cert_domains) > 0
    error_message = "At least one domain must be specified in cert_domains."
  }
}

variable "user_name" {
  description = "The name for the IAM user"
  type        = string
}

variable "user_description" {
  description = "A description tag for the IAM user explaining its purpose"
  type        = string
}
