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

//MARK: - Convert To DTO
extension UpbitWebsocketOrderBook {
    func toDomain() -> OrderBookDepthDTO {
        let paymentCurrency = market.split(separator: "-").map { String($0) }.first
        
        
        let bids = data.map { OrderBookDepthDTO.OrderBookData.init(type: .bid, price: $0.bidPrice, quantity: $0.bidSize, paymentCurrency: paymentCurrency) }
        
        let asks = data.map {
            OrderBookDepthDTO.OrderBookData.init(type: .bid, price: $0.askPrice, quantity: $0.askSize, paymentCurrency: paymentCurrency)
        }
        
        return OrderBookDepthDTO(bids: bids, asks: asks)
    }
}
