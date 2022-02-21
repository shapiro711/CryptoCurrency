//
//  UpbitMarket.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitMarket {
    let market: String
    let koreanName: String
    let englishName: String
}

extension UpbitMarket: Decodable {
    enum CodingKeys: String, CodingKey {
        case market
        case koreanName = "korean_name"
        case englishName = "english_name"
    }
}

//MARK: - Convert To DTO
extension UpbitMarket {
    func toDomain() -> MarketDTO {
        return MarketDTO(market: market,
                         koreanName: koreanName,
                         englishName: englishName)
    }
}
