//
//  UpbitSubscriptionMessage.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitSubscriptionMessage{
    var ticket: String = UUID().uuidString
    let type: String
    let codes: [String]
}

extension UpbitSubscriptionMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case ticket, type, codes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        var ticketContainer = container.nestedContainer(keyedBy: CodingKeys.self)
        try ticketContainer.encode(self.ticket, forKey: .ticket)
        var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self)
        try nestedContainer.encode(self.type, forKey: .type)
        try nestedContainer.encode(self.codes, forKey: .codes)
    }
}
