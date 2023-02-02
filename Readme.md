# Sample Code: Swift AWS Lambda

This is a sample AWS lambda function using the Swift runtime.

The handler is an implementation of a [WebFinger](https://www.rfc-editor.org/rfc/rfc7033) account request.  It can be used for when you want to have a [Mastodon address with a custom domain](https://www.kobachi.jp/posts/2023/mastodon-custom-alias.html) but don't want to respond to account requests with a static JSON file.  The solution of using a static JSON file works completely ignores the query string and always returns the same account, no matter the requested resource.

The implementation here uses a static lookup table to serve responses and returns HTTP `404` for unknown accounts, therefore doesn't work like a catch-all, as the static JSON file solution does.

## AWS preparation

You can run the function locally (see below) but if you want to actually deploy it to AWS, need to do some preparation.

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

As a sidenote, if you're planning to use something like this in production, you'd need to make sure your CDN passes along the query strings as that is often off by default for security reasons.  For example, if you use CloudFront you'd have to set up your Lambda function URL as origin and add a behavior to forward `.well-known/webfinger` to it, make sure to set it up to forward all necessary query parameters, this is off by default.  Either turn off caching or chose "Legacy cache settings" > "Query strings" > "All".

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

## Debugging

Set the `DEBUG_LOG_ENABLED` environment variable to `true` to log requests.

This will use the context logger to output the received event. These logs can be viewed in the CloudWatch log stream for your Lambda function log group (in `/aws/lambda/<function-name>`).

## Running locally

Make sure the run scheme for the executable has the `LOCAL_LAMBDA_SERVER_ENABLED` environment variable set to `true` and then build and run.

You can then send a request to `127.0.0.1:7000/invoke`.  While the public API is to use `GET` with query parameter to call the endpoint, for local testing, you must construct the JSON request yourself and use `POST` with a body instead.

The minimum viable JSON that contains all mandatory fields to be decodable as a `AWSLambdaEvents/APIGatewayV2Request` with the fields we're interested in looks like this: 

```sh
read -r -d '' REQUEST_BODY << EOM
{
    "version": "",
    "routeKey": "",
    "rawPath": "",
    "rawQueryString": "",
    "headers": {},
    "queryStringParameters": {
        "resource": "acct:alice@wonderland.com"
    },
    "requestContext": {
        "accountId": "",
        "apiId": "",
        "domainName": "",
        "domainPrefix": "",
        "http": {
            "method": "GET",
            "path": "",
            "protocol": "",
            "sourceIp": "",
            "userAgent": ""
        },
        "requestId": "",
        "routeKey": "",
        "stage": "",
        "time": "",
        "timeEpoch": 0
    },
    "isBase64Encoded": false
}
EOM
```

Then send the request with curl:

```sh
curl -X POST "127.0.0.1:7000/invoke" -H 'Content-Type: application/json' -d $REQUEST_BODY | jq
```

## References

- [WWDC 2020; Use Swift on AWS Lambda with Xcode](https://developer.apple.com/videos/play/wwdc2020/10644/)
- [AWS re:Invent 2020: Serverless, the Swift way](https://www.youtube.com/watch?v=tOwBaO0JAMs)
