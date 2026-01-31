output "access_key_id" {
  description = "The Access Key ID for the IAM user"
  value       = aws_iam_access_key.acme.id
}

output "secret_access_key" {
  description = "The Secret Access Key for the IAM user"
  value       = aws_iam_access_key.acme.secret
  sensitive   = true
}

output "iam_user_arn" {
  description = "The ARN of the IAM user"
  value       = aws_iam_user.acme.arn
}

output "allowed_record_names" {
  description = "The calculated list of ACME challenge record names (for debugging)"
  value       = local.acme_challenge_records
}
