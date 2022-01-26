//
//  OrderBookTableViewDataSource.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/26.
//

import UIKit

final class OrderBookTableViewDataSource: NSObject {
    private var orderBookDepth: OrderBookDepthDTO?
}

extension OrderBookTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return orderBookDepth?.asks?.count ?? 0
        } else {
            return orderBookDepth?.bids?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookAskTableViewCell.identifier, for: indexPath) as? OrderBookAskTableViewCell,
                  let asks = orderBookDepth?.asks else {
                      return UITableViewCell()
                  }
            
            let askOrder = asks[indexPath.row]
            cell.configure(by: askOrder)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderBookBidTableViewCell.identifier, for: indexPath) as? OrderBookBidTableViewCell,
                  let bids = orderBookDepth?.bids else {
                      return UITableViewCell()
                  }
            
            let bidOrder = bids[indexPath.row]
            cell.configure(by: bidOrder)
            
            return cell
        }
    }
}