//
//  RestTicker.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/15.
//

import Foundation

struct RestTicker {
    let symbol: String?
    let tradeDate: String?
    let tradeTime: String?
    let tradeDateKst: String?
    let tradeTimeKst: String?
    let tradeTimestamp: Double?
    let openPrice: Double?
    let highPrice: Double?
    let lowPrice: Double?
    let tradePrice: Double?
    let previousDayClosingPrice: Double?
    let change: String?
    let changePrice: Double?
    let changeRate: Double?
    let signedChangePrice: Double?
    let signedChangeRate: Double?
    let tardeVolume: Double?
    let accumulatedTransactionAmount: Double?
    let accumulatedTransactionAmount24H: Double?
    let accumulatedTransactionVolume: Double?
    let accumulatedTransactionVolume24H: Double?
    let highestPrice52Week: Double?
    let highestDate52Week: String?
    let lowestPrice52Week: Double?
    let lowestDate52Week: String?
    let timeStamp: Double?
}

extension RestTicker: Decodable {
    enum CodingKeys: String, CodingKey {
        case symbol = "market"
        case tradeDate = "trade_date"
        case tradeTime = "trade_time"
        case tradeDateKst = "trade_date_kst"
        case tradeTimeKst = "trade_time_kst"
        case tradeTimestamp = "trade_timestamp"
        case openPrice = "opening_price"
        case highPrice = "high_price"
        case lowPrice = "low_price"
        case tradePrice = "trade_price"
        case previousDayClosingPrice = "prev_closing_price"
        case change = ""
        case changePrice = "change_price"
        case changeRate = "change_rate"
        case signedChangePrice = "signed_change_price"
        case signedChangeRate = "signed_change_rate"
        case tardeVolume = "trade_volume"
        case accumulatedTransactionAmount = "acc_trade_price"
        case accumulatedTransactionAmount24H = "acc_trade_price_24h"
        case accumulatedTransactionVolume = "acc_trade_volume"
        case accumulatedTransactionVolume24H = "acc_trade_volume_24h"
        case highestPrice52Week = "highest_52_week_price"
        case highestDate52Week = "highest_52_week_date"
        case lowestPrice52Week = "lowest_52_week_price"
        case lowestDate52Week = "lowest_52_week_date"
        case timeStamp = "timestamp"
    }
}

//MARK: - Convert To DTO
extension RestTicker {
    func toDomain(symbol: String) -> TickerDTO {
        return TickerDTO(symbol: symbol, data: .init(currentPrice: tradePrice,
                                                     rateOfChange: signedChangeRate,
                                                     amountOfChange: signedChangePrice,
                                                     accumulatedTransactionAmount: accumulatedTransactionAmount24H,
                                                     previousDayClosingPrice: accumulatedTransactionAmount24H))
    }
}
