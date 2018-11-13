//
//  UITimelineScene.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 09/10/18.
//

import UIKit

open class UITableScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: InteractorProtocol, TInteractorProtocol>: UIScene<TPresenter, TInteractor, TInteractorProtocol> {
    var dataSource: UITableDataSource?
    
    @IBOutlet public weak var tableView: UITableView! {
        didSet {
            dataSource = self.loadDataSource()
            
            tableView.rowHeight = UITableView.automaticDimension
            
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
                self.tableView.performBatchUpdates({})
            }
        }
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
                        self.tableView?.insertRows(at: indexesPath, with: .automatic)
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
        guard let tableView = tableView, let dataSource = dataSource else {
            fatalError("Table has not yet been initialized")
        }
        
        tableView.register(UINib(nibName: "\(cell)", bundle: nil), forCellReuseIdentifier: "\(cell)")
        dataSource.bind(cell: cell, to: viewModel)
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
