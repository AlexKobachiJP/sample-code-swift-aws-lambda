// Copyright © 2022 Alex Kovács. All rights reserved.

import AWSLambdaRuntime
import AWSLambdaEvents

@main
struct WebFingerHandler: SimpleLambdaHandler {
    func handle(_ event: APIGatewayV2Request, context: LambdaContext) async throws -> APIGatewayV2Response {
        let resourceKey = "resource"
        let accountPrefix = "acct:"
        guard let resource = event.queryStringParameters?[resourceKey],
                resource.hasPrefix(accountPrefix) else {
            return APIGatewayV2Response(statusCode: .badRequest)
        }

        let account = String(resource.dropFirst(accountPrefix.count))

        guard let body = Account.lookup[account] else {
            return APIGatewayV2Response(statusCode: .notFound)
        }

        let headers = ["Content-Type": "application/json"]
        return APIGatewayV2Response(statusCode: .ok, headers: headers, body: body)
    }
}
