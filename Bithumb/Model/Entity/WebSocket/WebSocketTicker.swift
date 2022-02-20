//
//  WebSocketTicker.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/12.
//

import Foundation

enum CriteriaOfChange: String {
    case thirtyMinutesAgo = "30M"
    case oneHourAgo = "1H"
    case twelveHoursAgo = "12H"
    case twentyFourHoursAgo = "24H"
    case yesterdayMidnight = "MID"
    
    var jsonValue: String {
        return self.rawValue
    }
}

struct WebSocketTicker2 {
    let type: String?
    let symbol: String?
    let openPrice: Double?
    let highPrice: Double?
    let lowPrice: Double?
    let tradePirce: Double?
    let previousDayClosingPrice: Double?
    let change: String?
    let changePrice: Double?
    let signedChangePrice: Double?
    let changeRate: Double?
    let signedChangeRate: Double?
    let tardeVolume: Double?
    let accumulatedTransactionVolume: Double?
    let accumulatedTransactionVolume24H: Double?
    let accumulatedTransactionAmount: Double?
    let accumulatedTransactionAmount24H: Double?
    let currentTradeDate: String?
    let currentTradeTime: String?
    let tardeTimestamp: Double
    let askBid: String?
    let accmulatedAskVolume: Double?
    let accmulatedBidVolume: Double?
    let highestPrice52Week: Double?
    let highestDate52Week: String?
    let lowestPrice52Week: Double?
    let lowestDate52Week: String?
    let marketState: String?
    let isTradingSuspended: Bool?
    let delistingDate: Date?
    let marketWraning: String?
    let timeStamp: Double?
    let streamType: String?
}

extension WebSocketTicker2 {
    enum CodingKeys: String, CodingKey {
        case type
        case symbol = "code"
        case openPrice = "opening_price"
        case highPrice = "high_price"
        case lowPrice = "low_price"
        case tradePirce = "trade_price"
        case previousDayClosingPrice = "prev_closing_price"
        case change = "change"
        case changePrice = "change_price"
        case signedChangePrice = "signed_change_price"
        case changeRate = "change_rate"
        case signedChangeRate = "signed_change_rate"
        case tardeVolume = "trade_volume"
        case accumulatedTransactionVolume = "acc_trade_volume"
        case accumulatedTransactionVolume24H = "acc_trade_volume_24h"
        case accumulatedTransactionAmount = "acc_trade_price"
        case accumulatedTransactionAmount24H = "acc_trade_price_24h"
        case currentTradeDate = "trade_date"
        case currentTradeTime = "trade_time"
        case tardeTimestamp = "trade_timestamp"
        case askBid = "ask_bid"
        case accmulatedAskVolume = "acc_ask_volume"
        case accmulatedBidVolume = "acc_bid_volume"
        case highestPrice52Week = "highest_52_week_price"
        case highestDate52Week = "highest_52_week_date"
        case lowestPrice52Week = "lowest_52_week_price"
        case lowestDate52Week = "lowest_52_week_date"
        case marketState = "market_state"
        case isTradingSuspended = "is_trading_suspended"
        case delistingDate = "delisting_date"
        case marketWraning = "market_warning"
        case timeStamp = "timestamp"
        case streamType = "stream_type"
    }
}

struct WebSocketTicker {
    let symbol: String?
    let criteriaOfChange: CriteriaOfChange?
    let day: String?
    let time: String?
    let openPrice: Double?
    let closePrice: Double?
    let lowPrice: Double?
    let highPrice: Double?
    let accumulatedTransactionAmount: Double?
    let accumulatedTransactionVolume: Double?
    let accumulatedSellVolume: Double?
    let accumulatedBuyVolume: Double?
    let previousDayClosingPrice: Double?
    let rateOfChange: Double?
    let amountOfChange: Double?
    let volumePower: Double?
    
    var date: Date? {
        guard let day = day, let time = time else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.date(from: day + time)
    }
}

extension WebSocketTicker: Decodable {
    enum CodingKeys: String, CodingKey {
        case symbol, time, lowPrice, highPrice, volumePower
        case criteriaOfChange = "tickType"
        case day = "date"
        case openPrice = "openPrice"
        case closePrice = "closePrice"
        case accumulatedTransactionAmount = "value"
        case accumulatedTransactionVolume = "volume"
        case accumulatedSellVolume = "sellVolume"
        case accumulatedBuyVolume = "buyVolume"
        case previousDayClosingPrice = "prevClosePrice"
        case rateOfChange = "chgRate"
        case amountOfChange = "chgAmt"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try? values.decode(String.self, forKey: .symbol)
        criteriaOfChange = try? CriteriaOfChange(rawValue: values.decode(String.self, forKey: .criteriaOfChange))
        day = try? values.decode(String.self, forKey: .day)
        time = try? values.decode(String.self, forKey: .time)
        openPrice = try? Double(values.decode(String.self, forKey: .openPrice))
        closePrice = try? Double(values.decode(String.self, forKey: .closePrice))
        lowPrice = try? Double(values.decode(String.self, forKey: .lowPrice))
        highPrice = try? Double(values.decode(String.self, forKey: .highPrice))
        accumulatedTransactionAmount = try? Double(values.decode(String.self, forKey: .accumulatedTransactionAmount))
        accumulatedTransactionVolume = try? Double(values.decode(String.self, forKey: .accumulatedTransactionVolume))
        accumulatedSellVolume = try? Double(values.decode(String.self, forKey: .accumulatedSellVolume))
        accumulatedBuyVolume = try? Double(values.decode(String.self, forKey: .accumulatedBuyVolume))
        previousDayClosingPrice = try? Double(values.decode(String.self, forKey: .previousDayClosingPrice))
        rateOfChange = try? Double(values.decode(String.self, forKey: .rateOfChange))
        amountOfChange = try? Double(values.decode(String.self, forKey: .amountOfChange))
        volumePower = try? Double(values.decode(String.self, forKey: .volumePower))
    }
}

//MARK: - Convert To DTO
extension WebSocketTicker {
    func toDomain() -> TickerDTO {
        return TickerDTO(symbol: symbol, data: .init(currentPrice: closePrice,
                                                     rateOfChange: rateOfChange,
                                                     amountOfChange: amountOfChange,
                                                     accumulatedTransactionAmount: accumulatedTransactionAmount,
                                                     previousDayClosingPrice: previousDayClosingPrice))
    }
}
