//
//  NetworkConfigurable.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/15.
//

import Foundation

protocol NetworkConfigurable {
    func generateBaseURL(by api: ApiType) -> String
}

struct RestConfigure: NetworkConfigurable {
    private let bithumbBaseURLString = "https://api.bithumb.com"
    private let upbitBaseURLString = "https://api.upbit.com"
    
    func generateBaseURL(by api: ApiType) -> String {
        switch api {
        case .bithumb:
            return bithumbBaseURLString
        case .upbit:
            return upbitBaseURLString
        }
    }
}

struct WebSocketConfigure: NetworkConfigurable {
    private let bithumbBaseURLString = "wss://pubwss.bithumb.com"
    private let upbitBaseURLString = "wss://api.upbit.com"
    
    func generateBaseURL(by api: ApiType) -> String {
        switch api {
        case .bithumb:
            return bithumbBaseURLString
        case .upbit:
            return upbitBaseURLString
        }
    }
}
