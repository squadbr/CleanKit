//
//  UITableDataSource.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 09/10/18.
//

import UIKit

class UITableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    struct ViewModelItem {
        let identifier: String
        var item: TaggedViewModel
    }
    
    private weak var tableView: UITableView?
    private weak var delegate: ActionCenterDelegate?
    private var isLoading: Bool = false
    
    private var items: [ViewModelItem] = []
    private var identifiers: [String: String] = [:]
    internal var itemsToPrefetch: Int = 50
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    init(tableView: UITableView, delegate: ActionCenterDelegate) {
        self.tableView = tableView
        self.delegate = delegate
    }
    
    func append(collection: TaggedViewModelCollection) {
        DispatchQueue.async {
            guard let tableView = self.tableView else { return }
            
            // indexes of items to be inserted
            var indexesPath: [IndexPath] = []
            
            // get number of rows (must be on main thread)
            let semaphore = DispatchSemaphore(value: 0)
            var numberOfRows: Int!
            DispatchQueue.safeSync {
                numberOfRows = tableView.numberOfRows(inSection: 0)
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .distantFuture)
            
            // process each item
            for (index, item) in collection.items.enumerated() {
                let viewModel = "\(type(of: item))"
                
                if let identifier = self.identifiers[viewModel] {
                    self.items.append(ViewModelItem(identifier: identifier, item: item))
                    
                } else {
                    assertionFailure("The \(viewModel) view model is not binded")
                }
                
                indexesPath.append(IndexPath(row: index + numberOfRows, section: 0))
            }
            
            // insert items
            DispatchQueue.safeSync {
                UIView.performWithoutAnimation {
                    self.tableView?.insertRows(at: indexesPath, with: .none)
                }
                self.tableView?.tableFooterView = nil
            }
        }
    }
    
    func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        let current = identifiers["\(viewModel)"]
        
        precondition(current == nil, "The \(viewModel) is binded for \(current!)")
        identifiers["\(viewModel)"] = "\(cell)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.items[safe: indexPath.row] else {
            return UITableViewCell(frame: .zero)
        }
        
        if var cell = tableView.dequeueReusableCell(withIdentifier: item.identifier) as? UITableSceneCellProtocol {
            cell.delegate = delegate
            cell.tag = item.item.tag
            
            return cell.prepare(viewModel: item.item)
        } else {
            fatalError("The \(item.identifier) cell is not based on UITableSceneCell")
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row > self.items.count - self.itemsToPrefetch }) {
            delegate?.actionCenter(postAction: "prefetch", tag: 0)
        }
    }
    
    func showLoading() {
        guard let tableView = self.tableView else { return }
        self.spinner.frame.size = CGSize(width: tableView.frame.width, height: 80)
        tableView.tableFooterView = self.spinner
        self.spinner.startAnimating()
    }
    
    func stopLoading() {
        self.tableView?.tableFooterView = nil
    }
    
}
