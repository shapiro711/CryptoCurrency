//
//  WebSocketMessageHandler.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/21.
//

import Foundation

struct WebSocketMessageHandler {
    static func parse(_ message: URLSessionWebSocketTask.Message) -> WebSocketEvent {
        switch message {
        case .string(let stringMessage):
            guard let data = stringMessage.data(using: .utf8) else {
                return .receive(.unsupported)
            }
            if stringMessage.contains("status") {
                return checkConnection(from: data)
            } else if stringMessage.contains("type") {
                return decode(from: data)
            } else {
                return .receive(.unsupported)
            }
        default:
            return .receive(.unsupported)
        }
    }
    
    private static func checkConnection(from data: Data) -> WebSocketEvent {
        do {
            let parsedResult = try JSONDecoder().decode(ConnectionMessage.self, from: data)
            switch parsedResult.messageContent {
            case .connectedSuccessfully:
                return .connected
            case .subscribedSuccessfully:
                return .subscribed
            case .failedToSubscribe:
                return .error(.subscriptionFailed)
            default:
                return .receive(.unsupported)
            }
        } catch {
            return .error(.parsingFailed)
        }
    }
    
    private static func decode(from data: Data) -> WebSocketEvent {
        do {
            let deserializedResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let entityType = deserializedResult?["type"] as? String
            switch entityType {
            case "ticker":
                return .receive(.unsupported)
            case "transaction":
                return .receive(.unsupported)
            case "orderbookdepth":
                return .receive(.unsupported)
            default:
                return .receive(.unsupported)
            }
        } catch {
            return .error(.parsingFailed)
        }
    }
}

private struct WebSocketResponseData<Entity: Decodable> {
    struct CommonResponse: Decodable {
        let status: String
        let content: Entity
    }
    
    static func decode(data: Data) throws -> Entity {
        let result = try JSONDecoder().decode(CommonResponse.self, from: data)
        return result.content
    }
}
