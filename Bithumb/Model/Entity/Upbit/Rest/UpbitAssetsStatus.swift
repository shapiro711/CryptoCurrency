//
//  UpbitAssetsStatus.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/02/21.
//

import Foundation

struct UpbitAssetsStatus {
    let currency: String
    let walletState: String
}

extension UpbitAssetsStatus: Decodable {
    enum CodingKeys: String, CodingKey {
        case currency
        case walletState = "wallet_state"
    }
}
