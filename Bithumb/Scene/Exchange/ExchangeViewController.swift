//
//  ExchangeViewContorller.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/25.
//

import UIKit
import XLPagerTabStrip

enum TickerCriteria: String {
    case krw = "KRW"
    case btc = "BTC"
    case popularity = "인기"

    var title: String {
        return self.rawValue
    }
}

final class ExchangeViewContorller: SegmentedPagerTabStripViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isScrollEnabled = true
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let tickerViewControllerID = "TickerViewController"
        let favoriteTickerViewControllerID = "FavoriteTickerViewController"
        guard let krwTickerViewController = storyboard?.instantiateViewController(withIdentifier: tickerViewControllerID) as? TickerViewController,
              let btcTickerViewController = storyboard?.instantiateViewController(withIdentifier: tickerViewControllerID) as? TickerViewController,
              let favoritesTickerViewController = storyboard?.instantiateViewController(withIdentifier: favoriteTickerViewControllerID) as? FavoriteTickerViewController,
              let popularityTickerViewController = storyboard?.instantiateViewController(withIdentifier: tickerViewControllerID) as? TickerViewController else {
                  return []
              }
        
        krwTickerViewController.register(tickerCriteria: .krw)
        btcTickerViewController.register(tickerCriteria: .btc)
        popularityTickerViewController.register(tickerCriteria: .popularity)
        
        return [popularityTickerViewController, krwTickerViewController, btcTickerViewController, favoritesTickerViewController]
    }
}
