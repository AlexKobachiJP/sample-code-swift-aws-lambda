// Copyright © 2022 Alex Kovács. All rights reserved.

import AWSLambdaRuntime

enum EnvironmentVariables {}

#if DEBUG
extension EnvironmentVariables {
    static let localLambdaServerEnabled = "LOCAL_LAMBDA_SERVER_ENABLED"

    /// Checks the `LOCAL_LAMBDA_SERVER_ENABLED` environment variable and returns its Boolean value. Defaults to `false`.
    static var isLocalLambdaServerEnabled: Bool {
        Lambda.env(self.localLambdaServerEnabled).flatMap(Bool.init) ?? false
    }
}
#endif

extension EnvironmentVariables {
    static let debugLogEnabled = "DEBUG_LOG_ENABLED"

    /// Checks the `DEBUG_LOG_ENABLED` environment variable and returns its Boolean value. Defaults to `false`.
    static var isDebugLogEnabled: Bool {
        Lambda.env(self.debugLogEnabled).flatMap(Bool.init) ?? false
    }
}
