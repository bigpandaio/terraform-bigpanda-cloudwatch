# terraform-bigpanda-cloudwatch

This codebase is for setting up infrastruture using terraform for the BigPanda <=> CloudWatch integration. The AWS infrastructure will help send Cloudwatch alarms to a BigPanda Cloudwatch (inbound) integration created in the customer org.

## Instructions:
1. Create a main.tf file in your working directory using the below template:

```terraform
    module "cloudwatch" {
        source = "bigpandaio/cloudwatch/bigpanda"
        version = "1.0.0"
        api_endpoint = "<use endpoint from BigPanda integration>"
        app_key = "<use app_key from BigPanda integration>"
        bearer_token = "<use bearer_token from BigPanda integration>"
        subscribe_all = true
        daily_event_rule = true
    }

    provider "aws" {
        alias = "region"
    }

    data "aws_region" "current" {
        provider = aws.region
    }
```   

2. Run 

> terraform init

> terraform apply

Make sure the plan looks good.
In case, you need to delete the infrastructure created with terraform, run 

> terraform destroy

## Note:

1. Ensure the terraform state file is saved at an appropriate location.

2. It uses the current AWS region, which, unless specified, is the default region stored in AWS config file of the user running terraform.

3. Ensure that the user running ‘terraform apply’ command has permissions to create IAM role, policies and other resources like lambda function, SNS topic, SNS subscription, cloudwatch rule and cloudformation stack.

4. This terraform module uses 5 input variables: api_endpoint, app_key, bearer_token, subscribe_all, daily_event_rule. The api_endpoint, app_key and bearer_token need to be retrieved from the Cloudwatch integration created in BigPanda. subscribe_all and daily_event_rule accept boolean values and need to be set to “true” to create appropriate terraform resources.
