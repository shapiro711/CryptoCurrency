//
//  TransactionViewController.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/25.
//

import UIKit
import XLPagerTabStrip
import SpreadsheetView

final class TransactionViewController: UIViewController {
    //MARK: Properties
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private let spreadsheetView = SpreadsheetView()
    private let spreadsheetDataSource = TransactionSpreadsheetDataSource()
    private var symbol: String?
    private let repository: Repositoryable = Repository()
    private var closingPriceReceiveStatus = ClosingPriceReceiveStatus.notReceived
    private var apiType: ApiType = .upbit
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildHierachy()
        laysOutConstraint()
        setUpSpreadsheetView()
        repository.register(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerObserver()
        requestRestTransactionAPI()
        activityIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver()
        repository.execute(request: .disconnect)
    }
    
    func register(symbol: String?) {
        self.symbol = symbol
    }
    
    func register(apiType: ApiType) {
        self.apiType = apiType
    }
}

//MARK: - SetUp UI
extension TransactionViewController {
    private func buildHierachy() {
        view.addSubview(spreadsheetView)
    }
    
    private func laysOutConstraint() {        
        NSLayoutConstraint.activate([
            spreadsheetView.topAnchor.constraint(equalTo: view.topAnchor),
            spreadsheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spreadsheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spreadsheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpSpreadsheetView() {
        spreadsheetView.translatesAutoresizingMaskIntoConstraints = false
        spreadsheetView.showsHorizontalScrollIndicator = false
        spreadsheetView.bounces = false
        spreadsheetView.allowsSelection = false
        spreadsheetView.isDirectionalLockEnabled = true
        
        spreadsheetView.dataSource = spreadsheetDataSource
        
        spreadsheetView.register(TransactionAttributeSpreadSheetCell.self, forCellWithReuseIdentifier: TransactionAttributeSpreadSheetCell.identifier)
        spreadsheetView.register(TransactionTimeSpreadsheetCell.self, forCellWithReuseIdentifier: TransactionTimeSpreadsheetCell.identifier)
        spreadsheetView.register(TransactionPriceSpreadsheetCell.self, forCellWithReuseIdentifier: TransactionPriceSpreadsheetCell.identifier)
        spreadsheetView.register(TransactionQuantityTimeSpreadsheetCell.self, forCellWithReuseIdentifier: TransactionQuantityTimeSpreadsheetCell.identifier)
    }
}

//MARK: - Network
extension TransactionViewController {
    private func requestUpbitRestTransactionAPI() {
        guard let symbol = symbol else {
            return
        }
        
        let transactionRequest = UpbitTransactionReqeust.lookUp(market: symbol)
        repository.execute(request: transactionRequest) { [weak self] result in
            switch result {
            case .success(var transactions):
                transactions = transactions.map { (transaction: TransactionDTO) -> TransactionDTO in
                    var transaction = transaction
                    transaction.symbol = symbol
                    return transaction
                }
                self?.spreadsheetDataSource.configure(by: transactions)
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.spreadsheetView.reloadData()
                }
                self?.requestUpbitWebSocketOrderBookAPI(marketList: [symbol])
            case .failure(let error):
                UIAlertController.showAlert(about: error, on: self)
            }
        }
    }
    
    private func requestBithumbRestTransactionAPI() {
        guard let symbol = symbol else {
            return
        }
        
        let currencies = symbol.split(separator: "_").map { String($0) }
        guard let orderCurrency = currencies.first, let paymentCurrency = currencies.last else {
            return
        }
        
        let transactionRequest = TransactionRequest.lookUp(orderCurrency: orderCurrency, paymentCurrency: paymentCurrency)
        repository.execute(request: transactionRequest) { [weak self] result in
            switch result {
            case .success(var transactions):
                transactions = transactions.map { (transaction: TransactionDTO) -> TransactionDTO in
                    var transaction = transaction
                    transaction.symbol = symbol
                    return transaction
                }
                self?.spreadsheetDataSource.configure(by: transactions)
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.spreadsheetView.reloadData()
                }
                self?.requestWebSocketTransactionAPI(symbol: symbol)
            case .failure(let error):
                UIAlertController.showAlert(about: error, on: self)
            }
        }
    }
    
    private func requestRestTransactionAPI() {
        if apiType == .upbit {
            requestUpbitRestTransactionAPI()
        } else if apiType == .bithumb {
            requestBithumbRestTransactionAPI()
        } else {
            return
        }
    }
    
    private func requestUpbitWebSocketOrderBookAPI(marketList: [String]) {
        repository.execute(request: .connect(target: .upbitPublic))
        repository.execute(request: .send(message: .upbitTransaction(markets: marketList)))
    }
    
    private func requestWebSocketTransactionAPI(symbol: String) {
        repository.execute(request: .connect(target: .bitumbPublic))
        repository.execute(request: .send(message: .transaction(symbols: [symbol])))
    }
}

extension TransactionViewController: WebSocketDelegate {
    func didReceive(_ upbitMessageEvent: WebSocketUpbitResponseMessage) {
        switch upbitMessageEvent {
        case .transaction(let transaction):
            spreadsheetDataSource.update(by: [transaction])
            DispatchQueue.main.async {
                self.spreadsheetView.reloadData()
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
        case .transaction(let transactions):
            spreadsheetDataSource.update(by: transactions)
            DispatchQueue.main.async {
                self.spreadsheetView.reloadData()
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

//MARK: - Conform to IndicatorInfoProvider
extension TransactionViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        if let exchageDetailViewController = pagerTabStripController as? ExchangeDetailViewController {
            exchageDetailViewController.addObserver(observer: self)
        }
        return IndicatorInfo(title: "??????")
    }
}

//MARK: - Conform to AppLifeCycleOserverable
extension TransactionViewController: AppLifeCycleOserverable {
    func receiveForegoundNotification() {
        requestRestTransactionAPI()
    }
    
    func receiveBackgroundNotification() {
        repository.execute(request: .disconnect)
    }
}

//MARK: - Conform to ClosingPriceObserverable
extension TransactionViewController: ClosingPriceObserverable {
    func didReceive(previousDayClosingPrice: Double?) {
        spreadsheetDataSource.receive(previousDayClosingPrice: previousDayClosingPrice)
        
        if closingPriceReceiveStatus == .notReceived {
            DispatchQueue.main.async {
                self.spreadsheetView.reloadData()
            }
            closingPriceReceiveStatus = .received
        }
    }
}
