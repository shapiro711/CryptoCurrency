//
//  NetworkConfigurable.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/15.
//

import Foundation

protocol NetworkConfigurable {
    var baseURLString: String { get }
}

struct RestConfigure: NetworkConfigurable {
    //let baseURLString = "https://api.bithumb.com"
    let baseURLString = "https://api.upbit.com"
}

struct WebSocketConfigure: NetworkConfigurable {
    //let baseURLString = "wss://pubwss.bithumb.com"
    let baseURLString = "wss://api.upbit.com"
}
