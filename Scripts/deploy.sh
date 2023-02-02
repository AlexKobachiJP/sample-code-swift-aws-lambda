#!/bin/bash

set -eu

source ./Scripts/configuration.sh

DIRECTORY="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$DIRECTORY/.."

echo "👇 Deploying '$EXECUTABLE' from package at '$WORKSPACE'"
echo "👇 Preparing docker build image..."
docker build . -t builder

echo "👇 Building '$EXECUTABLE' lambda..."
docker run --rm -v "$WORKSPACE":/workspace -w /workspace builder \
    bash -cl "swift build --product '$EXECUTABLE' -c release"

echo "👇 Packaging '$EXECUTABLE' lambda..."
docker run --rm -v "$WORKSPACE":/workspace -w /workspace builder \
    bash -cl "./Scripts/package.sh '$EXECUTABLE' $AWS_S3_FILE"

echo "👇 Uploading '$EXECUTABLE' lambda to AWS S3..."
aws s3 cp ".build/lambda/$EXECUTABLE/$AWS_S3_FILE" "s3://$AWS_S3_BUCKET/$AWS_S3_FOLDER/" \
    --profile $AWS_PROFILE

echo "👇 Updating AWS Lambda to use '$EXECUTABLE'..."
aws lambda update-function-code --function "$AWS_LAMBDA_FUNCTION" \
    --s3-bucket "$AWS_S3_BUCKET" \
    --s3-key "$AWS_S3_FOLDER/$AWS_S3_FILE" \
    --profile $AWS_PROFILE
