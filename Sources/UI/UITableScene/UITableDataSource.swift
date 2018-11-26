//
//  UITableDataSource.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 09/10/18.
//

import UIKit

class UITableDataSource: NSObject {
    
    private weak var focusedCell: UITableSceneCellProtocol?
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
        return self.insert(collection: collection, at: self.items.count)
    }
    
    func insert(collection: TaggedViewModelCollection, at index: Int) -> [IndexPath] {
        var index: Int = index
        if self.reload {
            self.reload = false
            self.items = []
            index = 0
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
    
    func update(tag: Int, item: TaggedViewModel) {
        guard let index = (self.items.firstIndex { $0.item.tag == tag }) else { return }
        let viewModel = "\(type(of: item))"
        
        if let identifier = self.identifiers[viewModel] {
            self.items[index] = ViewModelItem(identifier: identifier, item: item)
        } else {
            assertionFailure("The \(viewModel) view model is not binded")
        }
        
        self.tableView?.performBatchUpdates({
            self.tableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        })
    }
    
    func remove(tag: Int) {
        guard let index = (self.items.firstIndex { $0.item.tag == tag }) else { return }
        
        self.items.remove(at: index)
        self.tableView?.performBatchUpdates({
            self.tableView?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        })
    }
    
    func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        self.tableView?.register(UINib(nibName: "\(cell)", bundle: nil), forCellReuseIdentifier: "\(cell)")
        
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier, for: indexPath) as? UITableSceneCellProtocol {
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

extension UITableDataSource {
    
    private func focusCell() {
        // unfocus
        self.focusedCell?.focus(bool: false)
        
        // get center
        guard let tableView = self.tableView else { return }
        let rect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // get visible cell that is at the center
        guard let indexPath = tableView.indexPathForRow(at: center) else { return }
        for visibleCell in tableView.visibleCells where tableView.indexPath(for: visibleCell) == indexPath {
            self.focusedCell = visibleCell as? UITableSceneCellProtocol
            self.focusedCell?.focus(bool: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? UITableSceneCellProtocol)?.focus(bool: false)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.focusCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.focusCell()
    }
    
}

extension UITableDataSource: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }
    
}
