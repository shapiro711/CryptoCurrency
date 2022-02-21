//
//  UpbitWebSocketOrderBook.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitWebsocketOrderBook {
    let market: String
    let data: [OrderData]
    
    struct OrderData: Decodable {
        let askSize: Double
        let bidSize: Double
        let askPrice: Double
        let bidPrice: Double
        
        enum CodingKeys: String, CodingKey {
            case askSize = "ask_size"
            case bidSize = "bid_size"
            case askPrice = "ask_price"
            case bidPrice = "bid_price"
        }
    }
}

extension UpbitWebsocketOrderBook: Decodable {
    enum CodingKeys: String, CodingKey {
        case market = "code"
        case data = "orderbook_units"
    }
}
