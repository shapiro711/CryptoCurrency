//
//  UpbitWebsocketTransaction.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitWebsocketTransaction {
    let market: String
    let orderType: String
    let price: Double
    let quantity: Double
    let dateTime: Double
    let upDown: String
    
    var date: Date? {
        return Date(timeIntervalSince1970: dateTime)
    }
}

extension UpbitWebsocketTransaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case market = "code"
        case orderType = "ask_bid"
        case price = "trade_price"
        case quantity = "trade_volume"
        case dateTime = "trade_timestamp"
        case upDown = "change"
    }
}

extension UpbitWebsocketTransaction {
    func toDomain() -> TransactionDTO {
        return TransactionDTO(date: date, price: price, quantity: quantity, type: OrderType.CalcultateUpbitOrderType(by: orderType), symbol: market)
    }
}
