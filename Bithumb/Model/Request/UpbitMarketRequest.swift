//
//  UpbitMarketRequest.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/22.
//

import Foundation

enum UpbitMarketRequest {
    case lookUpAll
}

extension UpbitMarketRequest: RestRequestable {
    var requestType: RequestType {
        return .ticker
    }
    
    var specificPath: String {
        return "/market/all"
    }
    
    var httpMethod: HTTPMethodType {
        return .get
    }
    
    var pathParameters: [PathParameterType: String]? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        return nil
    }
    
    var parser: (Data) -> Result<[MarketDTO], RestError> {
        return parseAllMarket
    }
}

extension UpbitMarketRequest {
    private func parseAllMarket(from data: Data) ->  Result<[MarketDTO], RestError> {
        do {
            let pareseResult = try JSONDecoder().decode([UpbitMarket].self, from: data)
            let dtos = pareseResult.map { $0.toDomain()}
            return .success(dtos)
        } catch{
            return .failure(.parsingFailed)
        }
    }
}
