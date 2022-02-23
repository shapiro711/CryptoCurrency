//
//  UpbitAsstesStatusReqeust.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/23.
//

import Foundation

enum UpbitAsstesStatusReqeust {
    case lookUp(market: String, listCount: Int = 20)
}

extension UpbitAsstesStatusReqeust: RestRequestable {
    var apiType: ApiType {
        .upbit
    }
    
    var requestType: RequestType {
        return .transaction
    }
    
    var specificPath: String {
        return "/trades/ticks"
    }
    
    var httpMethod: HTTPMethodType {
        switch self {
        case .lookUp:
            return .get
        }
    }
    
    var pathParameters: [PathParameterType: String]? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case .lookUp(let market, let listCount):
            var params = [String: Any]()
            params["market"] = market
            params["count"] = listCount
            return params
        }
    }
    
    var parser: (Data) -> Result<[TransactionDTO], RestError> {
        return parseTransactions
    }
}

extension UpbitAsstesStatusReqeust {
    private func parseTransactions(from data: Data) -> Result<[TransactionDTO], RestError> {
        do {
            let parsedResult = try JSONDecoder().decode([UpbitRestTransaction].self, from: data)
            let dtos = parsedResult.map { $0.toDomain()}
            return .success(dtos)
        } catch {
            return .failure(.parsingFailed)
        }
    }
}
