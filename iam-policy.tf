data "aws_iam_policy_document" "acme_dns01" {
  # Read-only permissions for zone discovery and change status
  statement {
    sid    = "AllowRoute53ReadAccess"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:GetChange",
    ]

    resources = ["*"]
  }

  # Write permission restricted to specific TXT records for ACME challenges
  statement {
    sid    = "AllowChangeACMEChallengeRecords"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]

    # Restrict to TXT records only
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["TXT"]
    }

    # Restrict to specific ACME challenge record names only
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values   = local.acme_challenge_records
    }
  }
}

resource "aws_iam_user_policy" "acme_dns01" {
  name   = "${var.user_name}-acme-dns01-policy"
  user   = aws_iam_user.acme.name
  policy = data.aws_iam_policy_document.acme_dns01.json
}
