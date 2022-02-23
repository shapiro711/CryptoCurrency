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
    
    var reqeustBasedOnCriteria: TickerRequest {
        switch self {
        case .krw, .btc:
            return TickerRequest.lookUpAll(paymentCurrency: self.rawValue)
        case .popularity:
            return TickerRequest.lookUpAll(paymentCurrency: "KRW")
        }
    }
    
    var title: String {
        return self.rawValue
    }
}

protocol changeAPIObserverable {
    func didRecive(apiType: ApiType)
}

final class ExchangeViewContorller: SegmentedPagerTabStripViewController {
    @IBOutlet private weak var selectAPIButton: UIButton!
    private var changeAPIObservers: [changeAPIObserverable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isScrollEnabled = true
        setupSelecAPIButton()
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
        
        changeAPIObservers.append(krwTickerViewController)
        changeAPIObservers.append(btcTickerViewController)
        changeAPIObservers.append(popularityTickerViewController)
        changeAPIObservers.append(favoritesTickerViewController)
        
        
        krwTickerViewController.register(tickerCriteria: .krw)
        btcTickerViewController.register(tickerCriteria: .btc)
        popularityTickerViewController.register(tickerCriteria: .popularity)
        
        return [popularityTickerViewController, krwTickerViewController, btcTickerViewController, favoritesTickerViewController]
    }
}

//MARK: - SetUp UI
extension ExchangeViewContorller {
    func setupSelecAPIButton() {
        let bithumb = UIAction(title: "Bithumb", state: .on) { [weak self] _ in
            self?.changeAPIObservers.forEach { $0.didRecive(apiType: .bithumb) }
        }
        let upbit = UIAction(title: "Upbit", state: .on) { [weak self] _ in
            self?.changeAPIObservers.forEach { $0.didRecive(apiType: .upbit) }
        }
        selectAPIButton.menu = UIMenu(title: "거래소 전환", children: [upbit, bithumb])
        selectAPIButton.translatesAutoresizingMaskIntoConstraints = false
    }
}
