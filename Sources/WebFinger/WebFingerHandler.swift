// Copyright © 2022 Alex Kovács. All rights reserved.

import AWSLambdaRuntime
import AWSLambdaEvents

@main
struct WebFingerHandler: SimpleLambdaHandler {
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
        guard EnvironmentVariables.isDebugLogEnabled else { return }

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
