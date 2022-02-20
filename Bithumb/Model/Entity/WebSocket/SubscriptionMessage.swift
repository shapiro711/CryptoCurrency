//
//  SubscriptionMessage.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/15.
//

import Foundation

struct SubscriptionMessage {
    let type: String
    let symbols: [String]
    let isOnlySnapshot: Bool?
    let isOnlyRealTime: Bool = true
}

extension SubscriptionMessage: Encodable {
    enum CodingKeys: String, CodingKey {
        case type, isOnlySnapshot
        case symbols = "codes"
        case isOnlyRealTime = "isOnlyRealtime"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(symbols, forKey: .symbols)
        try container.encode(isOnlySnapshot, forKey: .symbols)
        try container.encode(isOnlyRealTime, forKey: .symbols)
    }
}
