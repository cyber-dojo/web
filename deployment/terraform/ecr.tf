module "aws_ecr_repository" {
  count                = var.env == "staging" ? 1 : 0
  source               = "s3::https://s3-eu-central-1.amazonaws.com/terraform-modules-dacef8339fbd41ce31c346f854a85d0c74f7c4e8/terraform-modules.zip//ecr/v6"
  ecr_repository_name  = var.service_name
  image_tag_mutability = "IMMUTABLE"
  tags                 = module.tags.result
}

# Allow pull dev image for all Kosli org
data "aws_iam_policy_document" "allow_pull_from_org" {
  count = var.env == "staging" ? 1 : 0
  statement {
    sid    = "AllowPullFromOrg"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.org.id]
    }
  }
}

resource "aws_ecr_repository_policy" "allow_pull" {
  count      = var.env == "staging" ? 1 : 0
  repository = module.aws_ecr_repository[0].ecr_repository_name
  policy     = data.aws_iam_policy_document.allow_pull_from_org[0].json
}
