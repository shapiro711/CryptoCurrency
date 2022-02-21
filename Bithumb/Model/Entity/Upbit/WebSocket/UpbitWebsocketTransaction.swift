//
//  UpbitWebsocketTransaction.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitWebsocketTransaction {
    let market: String?
    let askBidType: String?
    let price: Double?
    let quantity: Double?
    let dateTime: Double?
    let upDown: String?
}

extension UpbitWebsocketTransaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case market = "code"
        case askBidType = "ask_bid"
        case price = "trade_price"
        case quantity = "trade_volume"
        case dateTime = "trade_timestamp"
        case upDown = "change"
    }
}
