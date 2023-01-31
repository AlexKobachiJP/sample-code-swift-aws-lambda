# Sample Code: Swift AWS Lambda

## Run locally

Make sure the run scheme for the executable has the `LOCAL_LAMBDA_SERVER_ENABLED` environment variable set to `true` and then build and run.

You can then send POST requests with curl:

```sh
curl -i -d '{"message":"Red hot chilli pepper 🌶️ "}' -H "Content-Type: application/json" 127.0.0.1:7000/invoke
```
