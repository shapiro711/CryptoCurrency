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
        return "/v1/ticker"
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
        var params = [PathParameterType: String]()
        
        switch self {
        case .lookUpAll(let marketList):
            var marketListString = marketList.reduce("") { $0 + "," + $1 }
            if marketListString.first == "," {
                marketListString.removeFirst()
            }
            params[.upbitMarket] = marketListString
        case .lookUp(let market):
            params[.upbitMarket] = market
        }
        
        return params
    }
    
    var queryParameters: [String: Any]? {
        return nil
    }
    
    var parser: (Data) -> Result<[TickerDTO], RestError> {
        switch self {
        case .lookUpAll:
            return parseAllTicker
        case .lookUp:
            return parseTicker
        }
        
    }
}

extension UpbitTickerRequest {
    private func parseAllTicker(from data: Data) ->  Result<[TickerDTO], RestError> {
        do {
            let pareseResult = try JSONDecoder().decode([UpbitRestTicker].self, from: data)
            let dtos = pareseResult.map { $0.toDomain()}
            return .success(dtos)
        } catch{
            return .failure(.parsingFailed)
        }
    }
    
    private func parseTicker(from data: Data) ->  Result<[TickerDTO], RestError> {
        do {
            let pareseResult = try JSONDecoder().decode(UpbitRestTicker.self, from: data)
            var dto: [TickerDTO] = []
            dto.append(pareseResult.toDomain())
            return .success(dto)
        } catch{
            return .failure(.parsingFailed)
        }
    }
}
