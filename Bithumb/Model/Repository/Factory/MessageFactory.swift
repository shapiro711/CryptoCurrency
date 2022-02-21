//
//  MessageFactory.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/20.
//

import Foundation

struct MessageFactory {
    static func makeSubscriptionMessage(from messageType: MessageType) -> SubscriptionMessage {
        switch messageType {
        case .ticker(let symbols, let tickTypes):
            return SubscriptionMessage(type: "ticker", symbols: symbols, criteriaOfChange: tickTypes, ticket: nil, codes: nil)
        case .transaction(let symbols):
            return SubscriptionMessage(type: "transaction", symbols: symbols, criteriaOfChange: nil, ticket: nil, codes: nil)
        case .orderBookDepth(let symbols):
            return SubscriptionMessage(type: "orderbookdepth", symbols: symbols, criteriaOfChange: nil, ticket: nil, codes: nil)
        case .upibtTicker(markets: let markets):
            return SubscriptionMessage(type: "ticker", symbols: nil, criteriaOfChange: nil, ticket: UUID().uuidString, codes: markets)
        }
    }
}
