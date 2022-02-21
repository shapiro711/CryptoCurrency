//
//  UpbitWebSocketTicker.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitWebsocketTicker {
    let market: String
    let signedChangeRate: Double
    let signedChangepPrice: Double
    let accumulatedTransactionValue: Double
    let accumulatedTransactionVolume: Double
    let change: String
    let currentPrice: Double
    let previousDayClosingPrice: Double
}

extension UpbitWebsocketTicker: Decodable {
    enum CodingKeys: String, CodingKey {
        case change
        case market = "code"
        case signedChangeRate = "signed_change_rate"
        case signedChangepPrice = "signed_change_price"
        case accumulatedTransactionValue = "acc_trade_price"
        case accumulatedTransactionVolume = "acc_trade_volume"
        case currentPrice = "trade_price"
        case previousDayClosingPrice = "prev_closing_price"
    }
}

//MARK: - Convert To DTO
extension UpbitWebsocketTicker {
    func toDomain() -> TickerDTO {
        return TickerDTO(symbol: market, data: .init(currentPrice: currentPrice,
                                                     rateOfChange: signedChangeRate,
                                                     amountOfChange: signedChangepPrice,
                                                     accumulatedTransactionAmount: accumulatedTransactionValue,
                                                     previousDayClosingPrice: previousDayClosingPrice))
    }
}
