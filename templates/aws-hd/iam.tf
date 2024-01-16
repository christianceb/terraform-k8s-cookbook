resource "aws_iam_user" "pipeline" {
  name = "pipeline_user"
  force_destroy = true
  permissions_boundary = data.aws_iam_policy.AmazonEC2ContainerRegistryPowerUser.arn

  tags = {
    project-is = var.project
  }
}

resource "aws_iam_access_key" "pipeline-access-key" {
  user = data.aws_iam_user.pipeline.id
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryPowerUser" {
  name = "AmazonEC2ContainerRegistryPowerUser"
}

output "pipeline-access-key-id" {
  value = data.aws_iam_access_key.id
}

output "pipeline-access-key-secret" {
  value = data.aws_iam_access_key.secret
  sensitive = true
}
