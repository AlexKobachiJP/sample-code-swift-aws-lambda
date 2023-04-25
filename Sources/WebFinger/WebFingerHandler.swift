// Copyright © 2023 Alex Kovács. All rights reserved.

import AWSLambdaRuntime
import AWSLambdaEvents

@main
struct WebFingerHandler: SimpleLambdaHandler {

    /// Handle request with query string: `"resource=acct:<account>"`.
    ///
    /// This handler assumes it will be called from a service that translates HTTP requests into events of type`APIGatewayV2Request`
    /// and expects response objects of type `APIGatewayV2Response`.  This is true for AWS API Gateway, CloudFront or when calling the
    /// Lambda function via its function URL.
    /// - Parameters:
    ///   - event: An `APIGatewayV2Request` with appropriate `queryStringParameters`.
    ///   - context: A `LambdaContext` that can be used, for example, to obtain a `logger`.
    /// - Returns: An `APIGatewayV2Response` with the response body expected by WebFinger.
    func handle(_ event: APIGatewayV2Request, context: LambdaContext) async throws -> APIGatewayV2Response {
        logEventIfNecessary(event, context: context)
        
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

#if DEBUG
import Foundation
#endif

extension WebFingerHandler {
    func logEventIfNecessary(_ event: APIGatewayV2Request, context: LambdaContext) {
        guard Environment.isDebugLogEnabled else { return }

#if DEBUG
        // Pretty print the output for local debugging.
        if EnvironmentVariables.isLocalLambdaServerEnabled {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            if let data = try? encoder.encode(event),
                let json = String(data: data, encoding: .utf8) {
                context.logger.info("\(json)")
            }

            return
        }
#endif

        context.logger.info("\(event)")
    }
}
