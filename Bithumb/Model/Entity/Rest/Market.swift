//
//  Market.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/20.
//

import Foundation

struct Market: Decodable {
    let symbol: String
    let koreanName: String
    let englishName: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "market"
        case koreanName = "korean_name"
        case englishName = "english_name"
    }
}


