#!/bin/bash

set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/config.sh

workspace="$DIR/../.."

echo -e "\ndeploying $executable"

$DIR/build-and-package.sh "$executable"

echo "-------------------------------------------------------------------------"
echo "uploading \"$executable\" lambda to AWS S3"
echo "-------------------------------------------------------------------------"

read -p "S3 bucket name to upload zip file (must exist in AWS S3): " s3_bucket
s3_bucket=${s3_bucket:-swift-lambda-test} # default for easy testing

aws s3 cp ".build/lambda/$executable/lambda.zip" "s3://$s3_bucket/"

echo "-------------------------------------------------------------------------"
echo "updating AWS Lambda to use \"$executable\""
echo "-------------------------------------------------------------------------"

read -p "Lambda Function name (must exist in AWS Lambda): " lambda_name
lambda_name=${lambda_name:-SwiftSample} # default for easy testing

aws lambda update-function-code --function "$lambda_name" --s3-bucket "$s3_bucket" --s3-key lambda.zip
