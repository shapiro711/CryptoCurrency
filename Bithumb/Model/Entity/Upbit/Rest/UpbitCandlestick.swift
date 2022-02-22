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
    let dateTimeKst: String
    
//    var date: Date {
//        return Date(timeIntervalSince1970: timestamp)
//    }
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.date(from: dateTimeKst) ?? Date()
    }
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
        case dateTimeKst = "candle_date_time_kst"
    }
}

//MARK: - Convert To DTO
extension UpbitCandlestick {
    func toDomain() -> CandlestickDTO {
        return CandlestickDTO(date: date,
                              openPrice: openPrice,
                              closePrice: closePrice,
                              highPrice: highPrice,
                              lowPrice: lowPrice,
                              volume: accmulatedTradeVolume)
    }
}

