//
//  UpbitRestTicker.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitRestTicker {
    let market: String?
    let openPrice: Double?
    let closePrice: Double?
    let lowPrice: Double?
    let highPrice: Double?
    let accumulatedTransactionVolume: Double?
    let accumulatedTransactionAmount: Double?
    let previousClosingPrice: Double?
    let accumulatedTransactionVolume24Hours: Double?
    let accumulatedTransactionAmount24Hours: Double?
    let signedChangepPrice: Double?
    let signedChangeRate: Double?
    let date: Double?
}

extension UpbitTicker: Decodable {
    enum CodingKeys: String, CodingKey {
        case market
        case openPrice = "opening_price"
        case closePrice = "trade_price"
        case lowPrice = "low_price"
        case highPrice = "high_price"
        case accumulatedTransactionVolume = "acc_trade_volume"
        case accumulatedTransactionAmount = "acc_trade_price"
        case previousClosingPrice = "prev_closing_price"
        case accumulatedTransactionVolume24Hours = "acc_trade_volume_24h"
        case accumulatedTransactionAmount24Hours = "acc_trade_price_24h"
        case signedChangepPrice = "signed_change_price"
        case signedChangeRate = "signed_change_rate"
        case date = "timestamp"
    }
}
