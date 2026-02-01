<!-- BEGIN_TF_DOCS -->
# AWS IAM Route53 ACME DNS-01 Challenge Module

This Terraform/OpenTofu module creates an IAM user with **least-privilege permissions** for managing Let's Encrypt/ACME DNS-01 challenge TXT records in AWS Route53.

## Features

- **Least-privilege IAM policy**: Restricts `ChangeResourceRecordSets` to only TXT records with `_acme-challenge.` prefix
- **Automatic domain transformation**: Converts input domains (including wildcards) to their corresponding ACME challenge record names
- **Fine-grained Route53 conditions**: Uses `route53:ChangeResourceRecordSetsRecordTypes` and `route53:ChangeResourceRecordSetsNormalizedRecordNames` conditions
- **Compatible with popular ACME clients**: Works with certbot-dns-route53, lego, acme.sh, Traefik, Caddy, and cert-manager
- **Multi-account support**: Supports passing an explicit AWS provider for cross-account Route53 access

## Usage

### Basic Usage

```hcl
module "acme_dns01_user" {
  source = "github.com/GlueOps/opentofu-module-AWS-IAM-route53-ACME-DNS"

  hosted_zone_id   = "Z1234567890ABC"
  user_name        = "acme-dns01-example-com"
  user_description = "ACME DNS-01 challenge user for example.com certificates"

  cert_domains = [
    "*.example.com",
    "example.com",
    "auth.example.com",
    "deep.sub.example.com",
  ]
}

# Use the credentials with your ACME client
output "access_key_id" {
  value = module.acme_dns01_user.access_key_id
}

output "secret_access_key" {
  value     = module.acme_dns01_user.secret_access_key
  sensitive = true
}
```

### Multi-Account Usage (Cross-Account Route53)

When your Route53 hosted zone is in a different AWS account, pass an explicit provider:

```hcl
# Provider for the account where Route53 is hosted
provider "aws" {
  alias  = "route53_account"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::111111111111:role/Route53AdminRole"
  }
}

module "acme_dns01_user" {
  source = "github.com/GlueOps/opentofu-module-AWS-IAM-route53-ACME-DNS"

  providers = {
    aws = aws.route53_account
  }

  hosted_zone_id   = "Z1234567890ABC"
  user_name        = "acme-dns01-example-com"
  user_description = "ACME DNS-01 challenge user for example.com certificates"

  cert_domains = [
    "*.example.com",
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.acme](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.acme](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.acme_dns01](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_policy_document.acme_dns01](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_domains"></a> [cert\_domains](#input\_cert\_domains) | List of domains/subdomains requiring certificates (e.g., ["*.example.com", "auth.example.com"]) | `list(string)` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | The Route53 Hosted Zone ID where ACME DNS-01 challenge records will be created | `string` | n/a | yes |
| <a name="input_user_description"></a> [user\_description](#input\_user\_description) | A description tag for the IAM user explaining its purpose | `string` | n/a | yes |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | The name for the IAM user | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | The Access Key ID for the IAM user |
| <a name="output_allowed_record_names"></a> [allowed\_record\_names](#output\_allowed\_record\_names) | The calculated list of ACME challenge record names (for debugging) |
| <a name="output_iam_user_arn"></a> [iam\_user\_arn](#output\_iam\_user\_arn) | The ARN of the IAM user |
| <a name="output_secret_access_key"></a> [secret\_access\_key](#output\_secret\_access\_key) | The Secret Access Key for the IAM user |
<!-- END_TF_DOCS -->
