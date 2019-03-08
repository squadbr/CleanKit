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

open class UITableScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: InteractorProtocol, TInteractorProtocol>: UIScene<TPresenter, TInteractor, TInteractorProtocol> {
    var dataSource: UITableDataSource?
    
    @IBOutlet public weak var tableView: UITableView! {
        didSet {
            dataSource = self.loadDataSource()
            
            tableView.rowHeight = UITableView.automaticDimension
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.estimatedSectionHeaderHeight = CGFloat.leastNonzeroMagnitude
            tableView.sectionFooterHeight = UITableView.automaticDimension
            tableView.estimatedSectionFooterHeight = CGFloat.leastNonzeroMagnitude
            
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            tableView.prefetchDataSource = dataSource
            
            setupTable()
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            if height != headerView.frame.height {
                headerView.frame.size.height = height
                self.tableView.tableHeaderView = headerView
                self.tableView.performBatchUpdates({})
            }
        }
    }
    
    @objc
    open func refresh() {
        self.dataSource?.clear()
    }
    
    open override func setup(actionCenter: ActionCenter) {
        actionCenter.observe(action: "delete") { [weak self] (tag) in
            guard let self = self, let dataSource = self.dataSource else { return }
            dataSource.remove(tag: tag)
        }
        actionCenter.observe(action: "update") { [weak self] (tag, any) in
            guard let self = self, let dataSource = self.dataSource, let item = any as? TaggedViewModel else { return }
            dataSource.update(tag: tag, item: item)
        }
    }
    
    open override func setup(viewModelCenter: ViewModelCenter) {
        viewModelCenter.observe(background: true) { [weak self] (collection: TaggedViewModelCollection) in
            guard let self = self, let dataSource = self.dataSource else { return }
            
            let indexesPath: [IndexPath]
            switch collection.case {
            case .append:
                indexesPath = dataSource.append(collection: collection)
            case let .insert(index, _):
                indexesPath = dataSource.insert(collection: collection, at: index)
            }
            
            DispatchQueue.safeSync {
                let firstIndexPath: IndexPath? = indexesPath.first
                if firstIndexPath == nil || firstIndexPath?.row == 0, case .append = collection.case {
                    // just reload data
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                    
                } else if case let .insert(index, animated) = collection.case, animated {
                    // insert animated
                    var time: Double = 0
                    
                    if let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows,
                        !indexPathsForVisibleRows.isEmpty {
                        
                        // scroll to position if exists
                        UIView.animate(withDuration: 0.75, animations: {
                            self.tableView.scrollToRow(at: firstIndexPath!, at: .none, animated: true)
                            time = 0.75
                        }, completion: { (_) in
                            insertAndScroll()
                        })
                        
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                            insertAndScroll()
                        })
                    }
                    
                    func insertAndScroll() {
                        self.tableView?.insertRows(at: indexesPath, with: .fade)
                        self.tableView.scrollToRow(at: firstIndexPath!, at: .none, animated: true)
                    }
                } else {
                    // insert
                    UIView.performWithoutAnimation {
                        self.tableView?.insertRows(at: indexesPath, with: .none)
                    }
                }
            }
        }
    }
    
    public func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        guard let dataSource = dataSource else {
            preconditionFailure("DataSource has not yet been initialized")
        }
        
        dataSource.bind(cell: cell, to: viewModel)
    }
    
    public func set<T: SectionViewModel>(sectionHeader header: UITableSceneSectionHeader<T>.Type, footer: UITableSceneSectionFooter.Type? = nil, feedback: UITableSceneSectionFeedback.Type? = nil) {
        guard let dataSource = dataSource else {
            preconditionFailure("Table has not yet been initialized")
        }
        
        dataSource.set(sectionHeader: header, footer: footer, feedback: feedback)
        
        presenter.viewModelCenter.observe(background: true) { [weak self] (viewModel: T) in
            guard let self = self, let dataSource = self.dataSource else { return }
            
            dataSource.updateOrCreate(sectionViewModel: viewModel)
            DispatchQueue.safeSync {
                self.tableView.reloadData()
            }
        }
    }
    
    open func setupTable() {
        assertionFailure("You need to implement the method \"setupTable()\" to prepare this table")
    }
    
    func loadDataSource() -> UITableDataSource {
        return UITableDataSource(tableView: self.tableView, delegate: self)
    }
    
    func remove(tag: Int) {
        self.dataSource?.remove(tag: tag)
    }
    
}
