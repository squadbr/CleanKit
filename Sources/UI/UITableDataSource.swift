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
    
    private var items: [ViewModelItem] = []
    private var identifiers: [String: String] = [:]
    
    init(tableView: UITableView, delegate: ActionCenterDelegate) {
        self.tableView = tableView
        self.delegate = delegate
    }
    
    func append(collection: TaggedViewModelCollection) {
        DispatchQueue.async {
            var indexesPath: [IndexPath] = []
            
            let semaphore = DispatchSemaphore(value: 0)
            var numberOfRows: Int!
            DispatchQueue.safeSync {
                numberOfRows = self.tableView!.numberOfRows(inSection: 0)
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .distantFuture)
            
            for item in numberOfRows..<collection.items.count+numberOfRows {
                indexesPath.append(IndexPath(row: item, section: 0))
            }
            
            // process collection
            for item in collection.items {
                let viewModel = "\(type(of: item))"
                
                if let identifier = self.identifiers[viewModel] {
                    self.items.append(ViewModelItem(identifier: identifier, item: item))
                    
                } else {
                    assertionFailure("The \(viewModel) view model is not binded")
                }
            }
            
            DispatchQueue.safeSync {
                UIView.performWithoutAnimation {
                    self.tableView?.insertRows(at: indexesPath, with: .none)
                }
            }
        }
    }
    
    func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        let current = identifiers["\(viewModel)"]
        
        precondition(current == nil, "The \(viewModel) is binded for \(current!)")
        identifiers["\(viewModel)"] = "\(cell)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.isEmpty ? 0 : self.items.count
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
        if indexPaths.contains(where: { $0.row > items.count - 25 }) {
            delegate?.actionCenter(postAction: "teste", tag: 0)
        }
    }
    
}
