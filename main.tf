terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "tf-state-bukala"
}

resource "aws_s3_bucket_versioning" "tfstate_version" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_db" {
  name = "terraform_db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "lock_id"
  attribute {
    name = "lock_id"
    type = "S"
  }
}

resource "aws_sns_topic" "serverless_sns" {
  name = "serverless1_sns_tf"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.serverless_sns.arn
  protocol = "email"
  endpoint = "263479@student.pwr.edu.pl"
}

resource "aws_dynamodb_table" "serverless_dynamodb" {
  name = "serverless1_dynamodb_tf"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "sensor_id"
  attribute {
    name = "sensor_id"
    type = "S"
  }
}

resource "aws_lambda_function" "serverless1_tf"{
    function_name = "serverless1_tf"
    role = "arn:aws:iam::697289770609:role/LabRole"
    handler = "lambda_serverless1_tf.lambda_handler"
    runtime = "python3.12"
    filename = "${path.module}/lambda_serverless1_tf.zip"
    source_code_hash = filebase64sha256("${path.module}/lambda_serverless1_tf.zip")

    environment {
      variables = {
        SNS_TOPIC_ARN = aws_sns_topic.serverless_sns.arn
        DDB_TABLE_ARN = aws_dynamodb_table.serverless_dynamodb.arn
      }
    }
}