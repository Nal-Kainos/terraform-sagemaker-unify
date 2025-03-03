provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "sagemaker_role" {
  name = "sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_sagemaker_model" "sagemaker_unify_model" {
  name               = "sagemaker-unify-model"
  execution_role_arn = aws_iam_role.sagemaker_role.arn

  primary_container {
    image = "763104351884.dkr.ecr.us-east-1.amazonaws.com/pytorch-inference:1.10.0-cpu-py38"
    mode  = "SingleModel"
  }
}

resource "aws_sagemaker_endpoint_configuration" "sagemaker_unify_config" {
  name = "sagemaker-unify-config"

  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.sagemaker_unify_model.name
    initial_instance_count = 1
    instance_type          = "ml.m5.large"
  }
}

resource "aws_sagemaker_endpoint" "sagemaker_unify_endpoint" {
  name               = "sagemaker-unify-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.sagemaker_unify_config.name
}
