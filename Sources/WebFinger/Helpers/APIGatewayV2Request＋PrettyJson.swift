// Copyright © 2025 Alex Kovács. All rights reserved.

import AWSLambdaEvents
import Foundation

extension APIGatewayV2Request {
  var prettyJson: String? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    if let data = try? encoder.encode(self) {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }
}
