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
        case .ticker(let symbols):
            return SubscriptionMessage(type: "ticker", symbols: symbols, isOnlySnapshot: nil)
        case .transaction(let symbols):
            return SubscriptionMessage(type: "transaction", symbols: symbols, isOnlySnapshot: nil)
        case .orderBookDepth(let symbols):
            return SubscriptionMessage(type: "orderbookdepth", symbols: symbols, isOnlySnapshot: nil)
        }
    }
}
