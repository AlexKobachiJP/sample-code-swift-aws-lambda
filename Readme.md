# Sample Code: Swift AWS Lambda

## Deployment

Note: The scripts assume you have the [jq](https://stedolan.github.io/jq/download/) command line tool installed.

### Mac M1 Considerations

Lambdas will run on an x86 processor by default. Building a Lambda with an M1 will create an arm-based executable which will not run on an x86 processor. Here are a few options for building Swift Lambdas on an M1:

1. Configure the Lambda to run on the [Graviton2](https://aws.amazon.com/blogs/aws/aws-lambda-functions-powered-by-aws-graviton2-processor-run-your-functions-on-arm-and-get-up-to-34-better-price-performance/) Arm-based processor.
2. Build with the x86 architecture by specifying `--platform linux/amd64` in all Docker 'build' and 'run' commands in `build-and-package.sh`.

### Deployment instructions using AWS CLI

Steps to deploy this sample to AWS Lambda using the AWS CLI:

1. Login to AWS Console and create an AWS Lambda with the following settings:
  * Runtime: Custom runtime
  * Handler: Can be any string, does not matter in this case

2. Build, package and deploy the Lambda

  ```
  ./scripts/deploy.sh
  ```

  Notes:
  - This script assumes you have AWS CLI installed and credentials setup in `~/.aws/credentials`.
  - The default lambda function name is `SwiftSample`. You can specify a different one updating `lambda_name` in `deploy.sh`
  - Update `s3_bucket=swift-lambda-test` in `deploy.sh` before running (AWS S3 buckets require a unique global name)
  - Both lambda function and S3 bucket must exist before deploying for the first time.

## Run locally

Make sure the run scheme for the executable has the `LOCAL_LAMBDA_SERVER_ENABLED` environment variable set to `true` and then build and run.

You can then send POST requests with curl:

```sh
curl -i -d '{"message":"Red hot chilli pepper 🌶️ "}' -H "Content-Type: application/json" 127.0.0.1:7000/invoke
```

## References

- https://developer.apple.com/videos/play/wwdc2020/10644/
- https://www.youtube.com/watch?v=tOwBaO0JAMs
