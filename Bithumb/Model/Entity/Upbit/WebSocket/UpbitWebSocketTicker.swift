//
//  UpbitWebSocketTicker.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitWebsocketTicker {
    let market: String
    var tickType: String = "24H"
    let accumulatedTradeValue: Double
    let signedChangeRate: Double
    let signedChangepPrice: Double
    let accumulatedTransactionVolume24Hours: Double
    let change: String
    let tradePrice: Double
}

extension UpbitWebsocketTicker: Decodable {
    enum CodingKeys: String, CodingKey {
        case tickType, change
        case market = "code"
        case accumulatedTradeValue = "acc_trade_price_24h"
        case signedChangeRate = "signed_change_rate"
        case signedChangepPrice = "signed_change_price"
        case accumulatedTransactionVolume24Hours = "acc_trade_volume_24h"
        case tradePrice = "trade_price"
    }
}
