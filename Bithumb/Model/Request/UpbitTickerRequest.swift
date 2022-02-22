//
//  UpbitTickerRequest.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

enum UpbitTickerRequest {
    case lookUpAll(marketList: [String])
    case lookUp(market: String)
}

extension UpbitTickerRequest: RestRequestable {
    var requestType: RequestType {
        return .ticker
    }
    
    var specificPath: String {
        return "/ticker"
    }
    
    var httpMethod: HTTPMethodType {
        switch self {
        case .lookUpAll:
            return .get
        case .lookUp:
            return .get
        }
    }
    
    var pathParameters: [PathParameterType: String]? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        var params = [String: Any]()
        
        switch self {
        case .lookUpAll(let marketList):
            var marketListString = marketList.reduce("") { $0 + "," + $1 }
            if marketListString.first == "," {
                marketListString.removeFirst()
            }
            params["markets"] = marketListString
        case .lookUp(let market):
            params["markets"] = market
        }
        
        return params
    }
    
    var parser: (Data) -> Result<[TickerDTO], RestError> {
        switch self {
        case .lookUpAll:
            return parseTicker
        case .lookUp:
            return parseTicker
        }
        
    }
}

extension UpbitTickerRequest {
    private func parseTicker(from data: Data) ->  Result<[TickerDTO], RestError> {
        do {
            let pareseResult = try JSONDecoder().decode([UpbitRestTicker].self, from: data)
            let dtos = pareseResult.map { $0.toDomain()}
            return .success(dtos)
        } catch{
            return .failure(.parsingFailed)
        }
    }
}
