resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_codebuild_project" "build_project" {
  name          = "codebuild-project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  
  artifacts {
    type = "CODEPIPELINE"
   
     }
//artifacts_location=aws_s3_bucket.codepipeline_bucket.name
 

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
    buildspec = "buildspec.yml"
  }


  source_version = "master"

  tags = {
    Environment = "${terraform.workspace}"
    Terraform   = "True"
  }
}

