resource "aws_iam_role" "codedeploy-role" {
  name = "codedeploy-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
 policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codedeploy-role.name
}

resource "aws_codedeploy_app" "codedeploy-app" {
  name = "codedeploy-application"
}



resource "aws_codedeploy_deployment_group" "codedeploy-group" {
  app_name              = aws_codedeploy_app.codedeploy-app.name
  deployment_group_name = "codedeploy-group"
  service_role_arn      = aws_iam_role.codedeploy-role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "jenkins-master-dev"
    }
  }


  auto_rollback_configuration {
    enabled = false
    events  = ["DEPLOYMENT_FAILURE"]
  }

  
}