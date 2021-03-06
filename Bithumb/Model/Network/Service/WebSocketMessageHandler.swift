//
//  WebSocketMessageHandler.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/21.
//

import Foundation

enum MessageParsingResult {
    case connectionEstablished
    case upibtmessage(WebSocketUpbitResponseMessage)
    case message(WebSocketResponseMessage)
    case subscription(WebSocketSubscriptionEvent)
    case error(WebSocketCommonError)
}

struct WebSocketMessageHandler {
    static func parse(_ message: URLSessionWebSocketTask.Message) -> MessageParsingResult {
        switch message {
        case .string(let stringMessage):
            guard let data = stringMessage.data(using: .utf8) else {
                return .message(.unsupported)
            }
            if stringMessage.contains("status") {
                return checkConnection(from: data)
            } else if stringMessage.contains("type") {
                return decode(from: data)
            } else {
                return .message(.unsupported)
            }
        case .data(let data):
            return decodeUpbitData(form: data)
        default:
            return .message(.unsupported)
        }
    }
    
    private static func checkConnection(from data: Data) -> MessageParsingResult {
        do {
            let parsedResult = try JSONDecoder().decode(ConnectionMessage.self, from: data)
            switch parsedResult.messageContent {
            case .subscribedSuccessfully:
                return .subscription(.subscribedSuccessfully)
            case .failedToSubscribe:
                return .subscription(.failedToSubscribe)
            case .connectedSuccessfully:
                return .connectionEstablished
            default:
                return .message(.unsupported)
            }
        } catch {
            return .error(.decodingFailed)
        }
    }
    
    private static func decodeUpbitData(form data: Data) -> MessageParsingResult {
        guard let stringData = String(data: data, encoding: .utf8) else {
            return .error(.decodingFailed)
        }
    
        do {
            if stringData.contains("ticker") {
                let tickerEntity = try JSONDecoder().decode(UpbitWebsocketTicker.self, from: data)
                return .upibtmessage(.ticker(tickerEntity.toDomain()))
            } else if stringData.contains("orderbook") {
                let orderbookEntity = try JSONDecoder().decode(UpbitWebsocketOrderBook.self, from: data)
                return .upibtmessage(.orderBook(orderbookEntity.toDomain()))
            } else if stringData.contains("trade"){
                let orderbookEntity = try JSONDecoder().decode(UpbitWebsocketTransaction.self, from: data)
                return .upibtmessage(.transaction(orderbookEntity.toDomain()))
            } else {
                return .error(.urlGeneration)
            }
        } catch {
            return .error(.decodingFailed)
        }
    }
    
    private static func decode(from data: Data) -> MessageParsingResult {
        do {
            let deserializedResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let entityType = deserializedResult?["type"] as? String
            switch entityType {
            case "ticker":
                let tickerEntity = try WebSocketResponseData<WebSocketTicker>.decode(data: data)
                return .message(.ticker(tickerEntity.toDomain()))
            case "transaction":
                let transactionEntities = try WebSocketResponseData<WebSocketTransactionHistory>.decode(data: data)
                let transactionDTOs = transactionEntities.transactions?.map { $0.toDomain() } ?? []
                return .message(.transaction(transactionDTOs))
            case "orderbookdepth":
                let orderBookEntity = try WebSocketResponseData<WebSocketOrderBook>.decode(data: data)
                return .message(.orderBook(orderBookEntity.toDomain()))
            default:
                return .message(.unsupported)
            }
        } catch {
            return .error(.decodingFailed)
        }
    }
}

private struct WebSocketResponseData<Entity: Decodable> {
    struct CommonResponse: Decodable {
        let type: String
        let content: Entity
    }
    
    static func decode(data: Data) throws -> Entity {
        let result = try JSONDecoder().decode(CommonResponse.self, from: data)
        return result.content
    }
}
