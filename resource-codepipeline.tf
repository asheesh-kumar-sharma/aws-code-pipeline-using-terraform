resource "aws_codepipeline" "codepipeline" {
  name     = "psl-pipeline-${terraform.workspace}"
  
  role_arn = aws_iam_role.codepipeline_role.arn
     artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.codecommit_repo_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "front-end-Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }

      
      
    }
     action {
      name             = "backend-build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["backend_build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.backend-build_project.name
      }

      
      
    }
      }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
      ApplicationName    = aws_codedeploy_app.codedeploy-app.name
      DeploymentGroupName= aws_codedeploy_deployment_group.codedeploy-group.deployment_group_name
          
    }
    }
}
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-bucket-2021"
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
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
EOF

}
