
resource "aws_codebuild_project" "backend-build_project" {
  name          = "backend-codebuild-project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
   
     }
 

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"


   
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codepipeline_bucket.id}/build-log"
    }
  }

#   source {
#     type            = "CODECOMMIT"
#     location   = var.codecommit_repo_name
#     Branch     = "master"
#  }
    source {
    type      = "CODEPIPELINE"
    buildspec = "backend-buildspec.yml"
  }


  source_version = "master"

  tags = {
    Environment = "${terraform.workspace}"
    Terraform   = "True"
  }
}

