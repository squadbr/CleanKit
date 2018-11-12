//
//  UITableDataSource.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 09/10/18.
//

import UIKit

class UITableDataSource: NSObject {
    
    private(set) weak var tableView: UITableView?
    private(set) weak var delegate: ActionCenterDelegate?
    
    private var reload: Bool = false
    
    internal var items: [ViewModelItem] = []
    private var identifiers: [String: String] = [:]
    private var heights: [IndexPath: CGFloat] = [:]
    
    internal var itemsToPrefetch: Int = 50
    
    init(tableView: UITableView, delegate: ActionCenterDelegate) {
        self.tableView = tableView
        self.delegate = delegate
    }
    
    func clear() {
        self.reload = true
    }
    
    func append(collection: TaggedViewModelCollection) -> [IndexPath] {
        if self.reload {
            self.reload = false
            self.items = []
        }
        
        // indexes of items to be inserted
        var indexesPath: [IndexPath] = []
        
        // get number of rows and size of table view (must be on main thread)
        let numberOfRows: Int = self.items.count
        
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
        
        return indexesPath
    }
    
    func insert(collection: TaggedViewModelCollection, at index: Int) -> [IndexPath] {
        if self.reload {
            self.reload = false
            self.items = []
        }
        
        // indexes of items to be inserted
        var indexesPath: [IndexPath] = []
        
        // process each item
        for (itemIndex, item) in collection.items.enumerated() {
            let viewModel = "\(type(of: item))"
            
            if let identifier = self.identifiers[viewModel] {
                self.items.insert(ViewModelItem(identifier: identifier, item: item), at: itemIndex + index)
            } else {
                assertionFailure("The \(viewModel) view model is not binded")
            }
            
            indexesPath.append(IndexPath(row: itemIndex + index, section: 0))
        }
        
        return indexesPath
    }
    
    func remove(tag: Int) {
        guard let index = (self.items.firstIndex { $0.item.tag == tag }) else { return }
        
        self.items.remove(at: index)
        self.tableView?.performBatchUpdates({
            self.tableView?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        })
    }
    
    func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        let current = identifiers["\(viewModel)"]
        
        precondition(current == nil, "The \(viewModel) is binded for \(current!)")
        identifiers["\(viewModel)"] = "\(cell)"
    }
    
}

extension UITableDataSource: UITableViewDataSource, UITableViewDelegate {
    
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
    
    // functions to calculate height
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.heights[indexPath] = cell.bounds.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heights[indexPath] ?? UITableView.automaticDimension
    }
    
}

extension UITableDataSource: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }
    
}
