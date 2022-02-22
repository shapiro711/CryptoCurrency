//
//  UpbitCandlestickReqeust.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/22.
//

import Foundation

enum UpbitCandlestickReqeust {
    case lookUp(market: String, charIntervals: ChartInterval = .twentyFourHours)
}

extension UpbitCandlestickReqeust: RestRequestable {
    var requestType: RequestType {
        return .ticker
    }
    
    var specificPath: String {
        return "/candles"
    }
    
    var httpMethod: HTTPMethodType {
        return .get
    }
    
    var pathParameters: [PathParameterType: String]? {
        var params = [PathParameterType: String]()
        switch self {
        case .lookUp(_, let charIntervals):
            params[.chartIntervals] = charIntervals.upbitPathValue
        }
        return params
    }
    
    var queryParameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .lookUp(let market, _):
            params["market"] = market
            params["count"] = 200
        }
        return params
    }
    
    var parser: (Data) -> Result<[CandlestickDTO], RestError> {
        return parseCandlestick
    }
}

extension UpbitCandlestickReqeust {
    private func parseCandlestick(from data: Data) ->  Result<[CandlestickDTO], RestError> {
        do {
            let pareseResult = try JSONDecoder().decode([UpbitCandlestick].self, from: data)
            let dtos = pareseResult.map { $0.toDomain()}
            return .success(dtos)
        } catch{
            return .failure(.parsingFailed)
        }
    }
}
