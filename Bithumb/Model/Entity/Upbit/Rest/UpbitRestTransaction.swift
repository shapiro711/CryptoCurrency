//
//  UpbitRestTransaction.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitRestTransaction {
    let price: Double
    let quantity: Double
    let date: Double
    let type: String
}

extension UpbitRestTransaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case price = "trade_price"
        case quantity = "trade_volume"
        case date = "timestamp"
        case type = "ask_bid"
    }
}

