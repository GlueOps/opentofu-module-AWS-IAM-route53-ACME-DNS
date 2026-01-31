locals {
  # Transform domains to ACME challenge record names:
  # 1. Strip wildcard prefix (*.) if present
  # 2. Prepend _acme-challenge.
  # 3. Append trailing dot for Route53 normalization
  # 4. Deduplicate the list
  acme_challenge_records = distinct([
    for domain in var.cert_domains :
    "_acme-challenge.${replace(domain, "/^\\*\\./", "")}."
  ])
}

resource "aws_iam_user" "acme" {
  name = var.user_name

  tags = {
    Description = var.user_description
  }
}

resource "aws_iam_access_key" "acme" {
  user = aws_iam_user.acme.name
}
