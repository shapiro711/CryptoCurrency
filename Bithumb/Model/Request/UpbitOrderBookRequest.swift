//
//  UpbitOrderBookRequest.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

enum UpbitOrderBookRequest {
    case lookUp(market: String)
}

extension UpbitOrderBookRequest: RestRequestable {
    var requestType: RequestType {
        return .ticker
    }
    
    var specificPath: String {
        return "/orderbook"
    }
    
    var httpMethod: HTTPMethodType {
        return .get
    }
    
    var pathParameters: [PathParameterType: String]? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        var params = [String: Any]()
        
        switch self {
        case .lookUp(let market):
            params["markets"] = market
        }
        
        return params
    }
    
    var parser: (Data) -> Result<OrderBookDepthDTO, RestError> {
        return parseOrderBook
    }
}

extension UpbitOrderBookRequest {
    private func parseOrderBook(from data: Data) ->  Result<OrderBookDepthDTO, RestError> {
        do {
            let pareseResult = try JSONDecoder().decode([UpbitRestOrderBook].self, from: data)
            return .success(pareseResult.first?.toDomain() ?? OrderBookDepthDTO(bids: [], asks: []))
        } catch{
            return .failure(.parsingFailed)
        }
    }
}
