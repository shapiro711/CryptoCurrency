//
//  UpbitCandlestick.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitCandlestick {
    let market: String
    let openPrice: Double
    let closePrice: Double
    let lowPrice: Double
    let highPrice: Double
    let accmulatedTradeVolume: Double
    let previousDayClosingPrice: Double?
    let timestamp: Double
}

extension UpbitCandlestick: Decodable {
    enum CodingKeys: String, CodingKey {
        case market, timestamp
        case openPrice = "opening_price"
        case closePrice = "trade_price"
        case lowPrice = "low_price"
        case highPrice = "high_price"
        case accmulatedTradeVolume = "candle_acc_trade_volume"
        case previousDayClosingPrice = "prev_closing_price"
    }
}
