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
    
    open override func setup(viewModelCenter: ViewModelCenter) {
        viewModelCenter.observe(background: true) { [weak self] (collection: TaggedViewModelCollection) in
            guard let self = self, let dataSource = self.dataSource else { return }
            
            let indexesPath: [IndexPath]
            if collection.index == -1 {
                indexesPath = dataSource.append(collection: collection)
            } else {
                indexesPath = dataSource.insert(collection: collection, at: collection.index)
            }
            
            DispatchQueue.safeSync {
                if indexesPath.first == IndexPath(row: 0, section: 0), collection.index == -1 {
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                } else {
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
    
}
