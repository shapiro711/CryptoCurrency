//
//  TickerViewController.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/12.
//

import UIKit
import XLPagerTabStrip

final class TickerViewController: UIViewController {
    @IBOutlet private weak var tickerTableView: UITableView!
    private let repository: Repositoryable = Repository()
    private let tickerTableViewDataSource = TickerTableViewDataSource()
    private var tickerCriteria: TickerCriteria = .krw
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        repository.register(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestRestTickerAPI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        repository.execute(request: .disconnect)
    }
    
    func register(tickerCriteria: TickerCriteria) {
        self.tickerCriteria = tickerCriteria
    }
}

extension TickerViewController {
    private func setUpTableView() {
        tickerTableView.dataSource = tickerTableViewDataSource
        tickerTableView.delegate = self
        tickerTableView.register(TickerTableViewCell.self, forCellReuseIdentifier: TickerTableViewCell.identifier)
    }
}

extension TickerViewController {
    private func requestRestTickerAPI() {
        let tickerRequest = tickerCriteria.reqeustBasedOnCriteria
        repository.execute(request: tickerRequest) { [weak self] result in
            switch result {
            case .success(let tickers):
                self?.tickerTableViewDataSource.configure(tickers: tickers)
                DispatchQueue.main.async {
                    self?.tickerTableView.reloadData()
                }
                let symbols = tickers.compactMap { $0.symbol }
                self?.requestWebSocketTickerAPI(symbols: symbols)
            case .failure(_):
                break
            }
        }
    }
    
    private func requestWebSocketTickerAPI(symbols: [String]) {
        repository.execute(request: .connect(target: .bitumbPublic))
        repository.execute(request: .send(message: .ticker(symbols: symbols)))
    }
}

extension TickerViewController: WebSocketDelegate {
    func didReceive(_ connectionEvent: WebSocketConnectionEvent) {
        
    }
    
    func didReceive(_ messageEvent: WebSocketResponseMessage) {
        switch messageEvent {
        case .ticker(let tickerDTO):
            guard let index = tickerTableViewDataSource.update(by: tickerDTO) else {
                return
            }
            DispatchQueue.main.async {
                self.tickerTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        default:
            break
        }
    }
    
    func didReceive(_ subscriptionEvent: WebSocketSubscriptionEvent) {
        
    }
    
    func didReceive(_ error: WebSocketCommonError) {
        
    }
}

extension TickerViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tickerCriteria.title)
    }
}

extension TickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let exchangeDetailViewController = storyboard?.instantiateViewController(withIdentifier: "ExchangeDetailViewController") as? ExchangeDetailViewController else {
            return
        }
        
        let symbol = tickerTableViewDataSource.findSymbol(by: indexPath.row)
        exchangeDetailViewController.register(symbol: symbol)
        
        navigationController?.pushViewController(exchangeDetailViewController, animated: true)
    }
}
