//
//  SubscriptionMessage.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/15.
//

import Foundation

struct SubscriptionMessage {
    let type: String?
    let symbols: [String]?
    let criteriaOfChange: [CriteriaOfChange]?
    
    let ticket: String?
    let codes: [String]?
}

extension SubscriptionMessage: Encodable {
    enum CodingKeys: String, CodingKey {
        case type, symbols, ticket, codes
        case criteriaOfChange = "tickTypes"
    }
    
    func encode(to encoder: Encoder) throws {
        if ticket != nil {
            var container = encoder.unkeyedContainer()

            var ticketContainer = container.nestedContainer(keyedBy: CodingKeys.self)
            try ticketContainer.encode(self.ticket, forKey: .ticket)

            var typeContainer = container.nestedContainer(keyedBy: CodingKeys.self)
            try typeContainer.encode(self.type, forKey: .type)
            try typeContainer.encode(self.codes, forKey: .codes)
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(type, forKey: .type)
            try container.encodeIfPresent(symbols, forKey: .symbols)
            try container.encodeIfPresent(criteriaOfChange?.map { $0.jsonValue }, forKey: .criteriaOfChange)
        }
    }
}

