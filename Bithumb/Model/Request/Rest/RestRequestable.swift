//
//  Requestable.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/14.
//

import Foundation

enum ApiType {
    case bithumb
    case upbit
}

enum RequestType {
    case ticker
    case orderBook
    case transaction
    case assetStatus
    case candlestick
}

enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
    var methodName: String {
        return self.rawValue
    }
}

enum PathParameterType: Hashable {
    case orderCurrency
    case paymentCurrency
    case chartIntervals
//    case upbitMarket
    case upbitCandlestick
}

protocol RestRequestable {
    associatedtype TargetDTO: DataTransferable
    
    var apiType: ApiType { get }
    var requestType: RequestType { get }
    var basicPath: String { get }
    var specificPath: String { get }
    var httpMethod: HTTPMethodType { get }
    var pathParameters: [PathParameterType: String]? { get }
    var queryParameters: [String: Any]? { get }
    var parser: (Data) -> Result<TargetDTO, RestError> { get }
}

extension RestRequestable {
    var apiType: ApiType {
        return .upbit
    }
    
    var basicPath: String {
        switch apiType {
        case .bithumb:
            return "/public"
        case .upbit:
            return "/v1"
        }
    }
}
