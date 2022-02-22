//
//  UpbitRestTransaction.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitRestTransaction {
    let price: Double
    let quantity: Double
    let dateTime: Double
    let orderType: String
    
    var date: Date? {
        return Date(timeIntervalSince1970: dateTime)
    }
}

extension UpbitRestTransaction: Decodable {
    enum CodingKeys: String, CodingKey {
        case price = "trade_price"
        case quantity = "trade_volume"
        case dateTime = "timestamp"
        case orderType = "ask_bid"
    }
}

//MARK: - Convert To DTO
extension UpbitRestTransaction {
    func toDomain() -> TransactionDTO {
        return TransactionDTO(date: date, price: price, quantity: quantity, type: OrderType.CalcultateUpbitOrderType(by: orderType), symbol: nil)
    }
}

