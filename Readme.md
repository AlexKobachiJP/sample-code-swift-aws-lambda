# Sample Code: Swift AWS Lambda

This is a sample AWS lambda function using the Swift runtime. 

## AWS preparation

- Create a function in AWS Lambda:
    - Use "custom runtime on Amazon Linux 2".
    - Set architecture to "arm64".
    - Leave code blank, you'll be uploading it as a Zip file via S3.
- Create an S3 bucket to upload the lambda's Zip file (required as the file size exceeds the maxium that can be uploaded directly).
- If you want to use the deployment script (see below) you need to create an AWS user with a permission policy that covers at least the following (replace the bucket and function `arn` with those created in the last step):
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "lambda:UpdateFunctionCode"
            ],
            "Resource": [
                "arn:aws:s3:::<bucket-name>/*",
                "arn:aws:lambda:<region>:<account>:function:<function-name>"
            ]
        }
    ]
}
```

## Deployment

Prerequisits:
- Update the configuration variables in `./Scripts/configuration.sh` with those you set up above.  
- Make sure credentials for `AWS_PROFILE` are set in `~/.aws/credentials`. 
- [Docker](https://docs.docker.com/desktop/install/mac-install/) is installed and running.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) is installed.

Run the deployment script from the project root directory:

```
# cd to project root
./Scripts/deploy.sh
```

## Running locally

Make sure the run scheme for the executable has the `LOCAL_LAMBDA_SERVER_ENABLED` environment variable set to `true` and then build and run.

You can then send POST requests with curl:

```sh
curl -i -d '{"message":"Red hot chilli pepper 🌶️ "}' -H "Content-Type: application/json" 127.0.0.1:7000/invoke
```

## References

- Configure the Lambda to run on the [Graviton2](https://aws.amazon.com/blogs/aws/aws-lambda-functions-powered-by-aws-graviton2-processor-run-your-functions-on-arm-and-get-up-to-34-better-price-performance/) Arm-based processor.
- https://developer.apple.com/videos/play/wwdc2020/10644/
- https://www.youtube.com/watch?v=tOwBaO0JAMs
