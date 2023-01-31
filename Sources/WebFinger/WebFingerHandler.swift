// Copyright © 2022 Alex Kovács. All rights reserved.

import AWSLambdaRuntime

struct Request: Codable {
    var message: String
}

struct Response: Codable {
    var message: String
}

@main
struct WebFingerHandler: SimpleLambdaHandler {
    func handle(_ request: Request, context: LambdaContext) async throws -> Response {
        let message = request.message
        let response = Response(message: "You sent: \(message)")
        return response
    }
}
