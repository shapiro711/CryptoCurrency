//
//  MarketDTO.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/22.
//

import Foundation

struct MarketDTO: DataTransferable {
    let market: String
    let koreanName: String
    let englishName: String
}

extension Array where Element == MarketDTO {
    func sorted(by tickerCritria: TickerCriteria) -> [MarketDTO] {
        switch tickerCritria {
        case .btc:
            return self.filter { marketDTO in
                let paymentCurrency = marketDTO.market.split(separator: "-").map { String($0) }
                if paymentCurrency.first == "BTC" {
                    return true
                } else {
                    return false
                }
            }
        case .krw:
            return self.filter { marketDTO in
                let paymentCurrency = marketDTO.market.split(separator: "-").map { String($0) }
                if paymentCurrency.first == "KRW" {
                    return true
                } else {
                    return false
                }
            }
        case .popularity:
            return self.filter { marketDTO in
                let paymentCurrency = marketDTO.market.split(separator: "-").map { String($0) }
                if paymentCurrency.first == "KRW" {
                    return true
                } else {
                    return false
                }
            }
        }
    }
}
