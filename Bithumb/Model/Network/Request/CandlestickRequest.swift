//
//  CandlestickAPI.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/15.
//

import Foundation

enum ChartInterval: String {
    case oneMinute = "1m"
    case threeMinutes = "3m"
    case fiveMinutes = "5m"
    case tenMinutes = "10m"
    case thirtyMinutes = "30m"
    case oneHour = "1h"
    case sixHours = "6h"
    case twelveHours = "12h"
    case twentyFourHours = "24h"
    
    var pathValue: String {
        return self.rawValue
    }
}

enum CandlestickRequest {
    case lookUp(orderCurrency: String = "BTC", paymentCurrency: String = "KRW", chartIntervals: ChartInterval = .twentyFourHours)
}

extension CandlestickRequest: RestRequestable {
    var requestType: RequestType {
        return .candlestick
    }
    
    var basicPath: String {
        return "candlestick/"
    }
    
    var httpMethod: HTTPMethodType {
        switch self {
        case .lookUp:
            return .get
        }
    }
    
    var pathParameters: [PathParameterType: String]? {
        switch self {
        case .lookUp(let orderCurrency, let paymentCurrency, let chartIntervals):
            var params = [PathParameterType: String]()
            params[.orderCurrency] = orderCurrency
            params[.paymentCurrency] = paymentCurrency
            params[.chartIntervals] = chartIntervals.pathValue
            return params
        }
    }
    
    var queryParameters: [String: Any]? {
        return nil
    }
}