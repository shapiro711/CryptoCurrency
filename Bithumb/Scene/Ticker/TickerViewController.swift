//
//  TickerViewController.swift
//  Bithumb
//
//  Created by Kim Do hyung on 2022/01/12.
//

import UIKit
import XLPagerTabStrip

class TickerViewController: UIViewController {
    //MARK: Properties
    @IBOutlet private weak var tickerTableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private let repository: Repositoryable = Repository()
    private let tickerTableViewDataSource = TickerTableViewDataSource()
    private var tickerCriteria: TickerCriteria = .krw
    private var marketList: [MarketDTO] = []
    private var apiType: ApiType = .upbit
    private var isViewDisplay = false
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        repository.register(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewDisplay = true
        registerObserver()
        reqeustRestTickerAPI()
        activityIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewDisplay = false
        removeObserver()
        repository.execute(request: .disconnect)
    }
    
    func register(tickerCriteria: TickerCriteria) {
        self.tickerCriteria = tickerCriteria
    }
}

//MARK: - SetUp UI
extension TickerViewController {
    private func setUpTableView() {
        tickerTableView.dataSource = tickerTableViewDataSource
        tickerTableView.delegate = self
        tickerTableView.register(TickerTableViewCell.self, forCellReuseIdentifier: TickerTableViewCell.identifier)
    }
}

//MARK: - Network
extension TickerViewController {
    private func requestMarketList() {
        let marketRequest = UpbitMarketRequest.lookUpAll
        repository.execute(request: marketRequest) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let markets):
                self.marketList = markets.sorted(by: self.tickerCriteria)
                self.requestUpbitRestTickerAPI()
            case .failure(let error):
                UIAlertController.showAlert(about: error, on: self)
            }
        }
    }
    
    private func requestBithumbRestTickerAPI() {
        let tickerRequest = tickerCriteria.reqeustBasedOnCriteria
        repository.execute(request: tickerRequest) { [weak self] result in
            switch result {
            case .success(var tickers):
                if self?.tickerCriteria == .popularity {
                    tickers.sort { $0.data.accumulatedTransactionAmount ?? 0 > $1.data.accumulatedTransactionAmount ?? 0 }
                }
                self?.tickerTableViewDataSource.configure(tickers: tickers)
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.tickerTableView.reloadData()
                }
                let symbols = tickers.compactMap { $0.symbol }
                self?.requestBithumbWebSocketTickerAPI(symbols: symbols)
            case .failure(let error):
                UIAlertController.showAlert(about: error, on: self)
            }
        }
    }
    
    private func requestUpbitRestTickerAPI() {
        let tickerRequest = UpbitTickerRequest.lookUpAll(marketList: marketList.map {$0.market})
        repository.execute(request: tickerRequest) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(var tickers):
                if self.tickerCriteria == .popularity {
                    tickers.sort { $0.data.accumulatedTransactionAmount ?? 0 > $1.data.accumulatedTransactionAmount ?? 0 }
                }
                self.tickerTableViewDataSource.configure(tickers: tickers)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tickerTableView.reloadData()
                }
                self.requestUpbitWebSocketTickerAPI(marketList: self.marketList.map { $0.market })
            case .failure(let error):
                UIAlertController.showAlert(about: error, on: self)
            }
        }
    }
    
    private func requestUpbitWebSocketTickerAPI(marketList: [String]) {
        repository.execute(request: .connect(target: .upbitPublic))
        repository.execute(request: .send(message: .upibtTicker(markets: marketList)))
    }
    
    private func requestBithumbWebSocketTickerAPI(symbols: [String]) {
        repository.execute(request: .connect(target: .bitumbPublic))
        repository.execute(request: .send(message: .ticker(symbols: symbols)))
    }
    
    private func reqeustRestTickerAPI() {
        if apiType == .bithumb {
            requestBithumbRestTickerAPI()
        } else if apiType == .upbit {
            requestMarketList()
        } else {
            return
        }
    }
}

extension TickerViewController: WebSocketDelegate {
    func didReceive(_ upbitMessageEvent: WebSocketUpbitResponseMessage) {
        switch upbitMessageEvent {
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
    
    func didReceive(_ connectionEvent: WebSocketConnectionEvent) {
        UIAlertController.showAlert(about: connectionEvent, on: self)
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
        UIAlertController.showAlert(about: subscriptionEvent, on: self)
    }
    
    func didReceive(_ error: WebSocketCommonError) {
        UIAlertController.showAlert(about: error, on: self)
    }
}

//MARK: - Conform to AppLifeCycleOserverable
extension TickerViewController: AppLifeCycleOserverable {
    func receiveForegoundNotification() {
        requestBithumbRestTickerAPI()
    }
    
    func receiveBackgroundNotification() {
        repository.execute(request: .disconnect)
    }
}

//MARK: - Conform to IndicatorInfoProvider
extension TickerViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tickerCriteria.title)
    }
}

//MARK: - Conform to UITableViewDelegate
extension TickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let exchangeDetailViewController = storyboard?.instantiateViewController(withIdentifier: "ExchangeDetailViewController") as? ExchangeDetailViewController else {
            return
        }
        
        let symbol = tickerTableViewDataSource.findSymbol(by: indexPath.row)
        let koreanName = tickerTableViewDataSource.findKoreanName(by: indexPath.row)
        
        exchangeDetailViewController.register(symbol: symbol)
        exchangeDetailViewController.register(koreanName: koreanName)
        exchangeDetailViewController.register(apiType: self.apiType)
        
        navigationController?.pushViewController(exchangeDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TickerTableViewCell else {
            return
        }
        
        let trend = tickerTableViewDataSource.bringTrend(by: indexPath.row)
        cell.sparkle(by: trend)
        tickerTableViewDataSource.resetTrend(by: indexPath.row)
    }
}

//MARK: - Conform to ChagneAPIObservable
extension TickerViewController: changeAPIObserverable {
    func didRecive(apiType: ApiType) {
        self.apiType = apiType
        
        if isViewDisplay {
            repository.execute(request: .disconnect)
            switch apiType {
            case .bithumb:
                requestBithumbRestTickerAPI()
            case .upbit:
                requestMarketList()
            }
        } else {
            return
        }
    }
}
