// Copyright © 2025 Alex Kovács. All rights reserved.

import AWSLambdaEvents
import AWSLambdaRuntime

func logEventIfNecessary(_ event: APIGatewayV2Request, context: LambdaContext) {
  guard Environment.isDebugLogEnabled else {
    return
  }

  #if DEBUG
    // Pretty print the output for local debugging.
    if Environment.isLocalLambdaServerEnabled,
      let json = event.prettyJson
    {
      context.logger.info("\(json)")
      return
    }
  #endif

  context.logger.info("\(event)")
}
