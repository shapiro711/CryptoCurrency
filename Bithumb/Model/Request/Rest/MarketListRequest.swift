//
//  MarketListRequest.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/20.
//

import Foundation

enum MarketListRequest {
    case lookUpAllMarketList
}

extension MarketListRequest: RestRequestable {
    
    var requestType: RequestType {
        return .marketList
    }
    
    var specificPath: String {
        return "/market/all"
    }
    
    var httpMethod: HTTPMethodType {
        switch self {
        case .lookUpAllMarketList:
            return .get
        }
    }
    
    var pathParameters: [PathParameterType: String]? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        return nil
    }
    
    var parser: (Data) -> Result<[MarketListDTO], RestError> {
        return parseMarketList
    }
}

extension MarketListRequest {
    private func parseMarketList(from data: Data) -> Result<[MarketListDTO], RestError> {
        do {
            let result = try JSONDecoder().decode([Market].self, from: data)
            let dto = result.map { MarketListDTO(symbols: $0.symbol) }
            return .success(dto)
        } catch  {
            return .failure(.parsingFailed)
        }
    }
}
