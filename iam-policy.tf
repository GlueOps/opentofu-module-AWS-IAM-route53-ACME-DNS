data "aws_iam_policy_document" "acme_dns01" {
  # Read-only permissions for zone discovery and change status
  statement {
    sid    = "AllowListHostedZones"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowGetChange"
    effect = "Allow"

    actions = [
      "route53:GetChange",
    ]

    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid    = "AllowListResourceRecordSets"
    effect = "Allow"

    actions = [
      "route53:ListResourceRecordSets",
    ]

    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]
  }

  # Write permission restricted to specific TXT records for ACME challenges
  statement {
    sid    = "AllowChangeACMEChallengeRecords"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]

    # Ensure the context keys are present (prevent empty set bypass)
    condition {
      test     = "Null"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["false"]
    }

    condition {
      test     = "Null"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values   = ["false"]
    }

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
