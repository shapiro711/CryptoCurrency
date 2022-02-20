//
//  TickerAPI.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/14.
//

import Foundation

enum TickerRequest {
    case lookUpAll(symbols:[String] = [])
    case lookUp(symbol: String = "KRW-BTC")
}

extension TickerRequest: RestRequestable {
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
        case .lookUpAll(let symbols):
            var symbolsString = symbols.reduce("") { $0 + "," + $1}
            if symbolsString.first == "," {
                symbolsString.removeFirst()
            }
            params["markets"] = symbolsString
        case .lookUp(let symbol):
            params["markets"] = symbol
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

extension TickerRequest {
    private func parseTicker(from data: Data) ->  Result<[TickerDTO], RestError> {
        do {
            let parsedResult = try JSONDecoder().decode([RestTicker].self, from: data)
            let dto = parsedResult.map { $0.toDomain(symbol: $0.symbol ?? "") }
            return .success(dto)
        } catch  {
            return .failure(.parsingFailed)
        }
    }
}
