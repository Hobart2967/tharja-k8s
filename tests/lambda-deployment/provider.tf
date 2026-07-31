provider "aws" {
  region   = "eu-central-1"
  insecure = var.skip_ssl_verification

  # LocalStack only:
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = var.environment_endpoint
    apigatewayv2   = var.environment_endpoint
    cloudformation = var.environment_endpoint
    cloudwatch     = var.environment_endpoint
    dynamodb       = var.environment_endpoint
    ec2            = var.environment_endpoint
    es             = var.environment_endpoint
    elasticache    = var.environment_endpoint
    firehose       = var.environment_endpoint
    iam            = var.environment_endpoint
    kinesis        = var.environment_endpoint
    lambda         = var.environment_endpoint
    rds            = var.environment_endpoint
    redshift       = var.environment_endpoint
    route53        = var.environment_endpoint
    s3             = var.s3_environment_endpoint
    secretsmanager = var.environment_endpoint
    ses            = var.environment_endpoint
    sns            = var.environment_endpoint
    sqs            = var.environment_endpoint
    ssm            = var.environment_endpoint
    stepfunctions  = var.environment_endpoint
    sts            = var.environment_endpoint
  }
}