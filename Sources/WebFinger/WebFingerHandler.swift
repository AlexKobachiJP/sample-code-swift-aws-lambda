// Copyright © 2022 Alex Kovács. All rights reserved.

import AWSLambdaRuntime

@main
struct WebFingerHandler: SimpleLambdaHandler {
    func handle(_ event: String, context: LambdaContext) async throws -> String {
        "hello, world"
    }
}
