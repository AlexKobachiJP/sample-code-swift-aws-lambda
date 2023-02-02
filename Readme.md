<span align="center">

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](./License.md)

</span>

# Sample Code: Swift AWS Lambda

This is a sample AWS lambda function using the Swift runtime.

The function handles a [WebFinger](https://www.rfc-editor.org/rfc/rfc7033) account request.  When you want to have a [Mastodon address with a custom domain](https://www.kobachi.jp/posts/2023/mastodon-custom-alias.html) without running your own Mastodon instance, you can deploy this function to serve requests to `.well-known/webfinger`.  One could just serve a static JSON file (as described in the linked article), but that solution completely ignores the query string (such as, `?resource=acct:alice@wonderland.com`) and always returns the same account, no matter the requested resource.

The implementation here returns HTTP `404` for unknown accounts and therefore doesn't work like a catch-all, as the static JSON file solution does.  For simplicity, I just use a static lookup table to manage accounts, as this is enough for my usecase.  The function also checks the query string format and returns HTTP `400` if it is malformed.

## AWS preparation

You can run the function locally (see below) but if you want to actually deploy it to AWS, you need to set a few things up:

- Create a function in AWS Lambda:
    - Use "custom runtime on Amazon Linux 2".
    - Set architecture to "arm64".
    - Leave code blank, you'll be uploading it as a Zip file via S3.
	- Turn on "function URL" with auth type set to "none".
- Create an S3 bucket to upload the lambda's Zip file (required as the file size exceeds the maxium that can be uploaded directly).
- If you want to use the deployment script (see below) you need to create an AWS user with a permission policy that covers at least the following (replace the bucket and function `ARN`s with those created in the last step):

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

As a sidenote, if you're planning to use something like this in production, you'd need to make sure your CDN passes along the query strings as that is often off by default for security reasons.  For example, if you use CloudFront you'd have to set up your Lambda function URL as origin and add a behavior to forward `.well-known/webfinger` to it.  For query strings to be passed along, you can either just turn off caching or chose "Legacy cache settings" > "Query strings" > "All".

## Deployment

Prerequisits:

- [Docker](https://docs.docker.com/desktop/install/mac-install/) is installed and running.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) is installed.
- Update the configuration variables in `./Scripts/configuration.sh` with those you set up above.  
- Make sure credentials for `AWS_PROFILE` are set in `~/.aws/credentials`. 

Run the deployment script from the project root directory:

```sh
# cd to project root
./Scripts/deploy.sh
```

## Debugging

Set the `DEBUG_LOG_ENABLED` environment variable to `true` to log requests.

This will use the context logger to output the received event. These logs can be viewed in the CloudWatch log stream for your Lambda function log group (in `/aws/lambda/<function-name>`).  The log stream doesn't handle pretty printed JSON well (it creates new log entries for each line break), the code therefore uses pretty printing only when the function is running locally.

## Running locally

Make sure the run scheme for the executable has the `LOCAL_LAMBDA_SERVER_ENABLED` environment variable set to `true` and then build and run in Xcode.

You can then send a request to `127.0.0.1:7000/invoke`.  While the public API is to use `GET` with query parameter to call the endpoint, for local testing, you must construct the JSON request yourself and use `POST` with a body instead.

The minimum viable JSON that contains all mandatory fields to be decodable as a `AWSLambdaEvents/APIGatewayV2Request` with the fields we're interested in looks like this: 

```sh
# Save JSON in environment variable:
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
curl -X POST "127.0.0.1:7000/invoke" -H 'Content-Type: application/json' -d $REQUEST_BODY
```

## References

- [WWDC 2020: Use Swift on AWS Lambda with Xcode](https://developer.apple.com/videos/play/wwdc2020/10644/)
- [AWS re:Invent 2020: Serverless, the Swift way](https://www.youtube.com/watch?v=tOwBaO0JAMs)
