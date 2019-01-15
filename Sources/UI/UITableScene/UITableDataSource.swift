//
//  Copyright (c) 2018 Squad
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class UITableDataSource: NSObject {
    
    private weak var focusedCell: UITableSceneCellProtocol?
    private(set) weak var tableView: UITableView?
    private(set) weak var delegate: ActionCenterDelegate?
    
    private var reload: Bool = false
    
    internal var items: [(viewModel: ViewModelItem, cellState: CellState?)] = []
    private var identifiers: [String: String] = [:]
    private var heights: [IndexPath: CGFloat] = [:]
    
    var itemsIsEmpty: Bool { return self.items.isEmpty }
    
    internal var itemsToPrefetch: Int = 50
    
    init(tableView: UITableView, delegate: ActionCenterDelegate) {
        self.tableView = tableView
        self.delegate = delegate
    }
    
    func clear(force: Bool = false) {
        self.reload = true
        if force {
            self.items = []
        }
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
                self.items.insert((ViewModelItem(identifier: identifier, item: item), nil), at: itemIndex + index)
            } else {
                assertionFailure("The \(viewModel) view model is not binded")
            }
            
            indexesPath.append(IndexPath(row: itemIndex + index, section: 0))
        }
        
        return indexesPath
    }
    
    func update(tag: Int, item: TaggedViewModel) {
        guard let index = (self.items.firstIndex { $0.viewModel.item.tag == tag }) else { return }
        let viewModel = "\(type(of: item))"
        
        if let identifier = self.identifiers[viewModel] {
            self.items[index].viewModel = ViewModelItem(identifier: identifier, item: item)
            self.items[index].cellState = nil
        } else {
            assertionFailure("The \(viewModel) view model is not binded")
        }
        
        self.tableView?.reloadData()
    }
    
    func remove(tag: Int) {
        guard let index = (self.items.firstIndex { $0.viewModel.item.tag == tag }) else { return }
        
        self.items.remove(at: index)
        self.tableView?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: item.viewModel.identifier, for: indexPath) as? UITableSceneCellProtocol {
            cell.delegate = delegate
            cell.tag = item.viewModel.item.tag
            
            let tableCell: UITableViewCell = cell.prepare(viewModel: item.viewModel.item)
            if let state = item.cellState {
                cell.restore(state)
            }
            
            return tableCell
        } else {
            fatalError("The \(item.viewModel.identifier) cell is not based on UITableSceneCell")
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
        guard let cell = cell as? UITableSceneCellProtocol else { return }
        cell.focus(bool: false)
        
        guard var item = self.items[safe: indexPath.row] else {
            return
        }
        item.cellState = cell.save()
        self.items[indexPath.row] = item
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
