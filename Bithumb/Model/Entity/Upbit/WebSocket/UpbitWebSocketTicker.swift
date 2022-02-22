//
//  UpbitWebSocketTicker.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitWebsocketTicker {
    let market: String?
    let signedChangeRate: Double?
    let signedChangepPrice: Double?
    let accumulatedTransactionValue: Double?
    let accumulatedTransactionVolume: Double?
    let change: String?
    let currentPrice: Double?
    let previousDayClosingPrice: Double?
}

extension UpbitWebsocketTicker: Decodable {
    enum CodingKeys: String, CodingKey {
        case change
        case market = "code"
        case signedChangeRate = "signed_change_rate"
        case signedChangepPrice = "signed_change_price"
        case accumulatedTransactionValue = "acc_trade_price_24h"
        case accumulatedTransactionVolume = "acc_trade_volume_24h"
        case currentPrice = "trade_price"
        case previousDayClosingPrice = "prev_closing_price"
    }
}

//MARK: - Convert To DTO
extension UpbitWebsocketTicker {
    func toDomain() -> TickerDTO {
        var rateOfChange: Double? = nil
        var amountOfChange: Double? = nil
        
        if let previousDayClosingPrice = previousDayClosingPrice,
           let currentPrice = currentPrice,
           previousDayClosingPrice != 0 {
            rateOfChange = (currentPrice / previousDayClosingPrice) - 1
            amountOfChange = currentPrice - previousDayClosingPrice
        }
        
        return TickerDTO(symbol: market, data: .init(currentPrice: currentPrice,
                                                     rateOfChange: rateOfChange,
                                                     amountOfChange: amountOfChange,
                                                     accumulatedTransactionAmount: accumulatedTransactionValue,
                                                     previousDayClosingPrice: previousDayClosingPrice))
    }
}
