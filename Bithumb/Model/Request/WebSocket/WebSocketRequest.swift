//
//  WebSocketRequest.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/19.
//

import Foundation

enum WebSocketType {
    case bitumbPublic
    case upbitPublic
    
    var path: String {
        switch self {
        case .bitumbPublic:
            return "/pub"
        case .upbitPublic:
            return "/websocket"
        }
    }
    
    var specificPath: String {
        switch self {
        case .bitumbPublic:
            return "/ws"
        case .upbitPublic:
            return "/v1"
        }
    }
}

enum MessageType {
    case ticker(symbols: [String], tickTypes: [CriteriaOfChange] = [.yesterdayMidnight])
    case transaction(symbols: [String])
    case orderBookDepth(symbols: [String])
    case upibtTicker(markets: [String])
    case upbitOrderBook(markets: [String])
    case upbitTransaction(markets: [String])
}

enum WebSocketRequest {
    case connect(target: WebSocketType)
    case disconnect
    case send(message: MessageType)
}


