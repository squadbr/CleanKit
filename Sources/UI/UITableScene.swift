//
//  UITimelineScene.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 09/10/18.
//

import UIKit

open class UITableScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: Interactor, TInteractorProtocol> : UIScene<TPresenter, TInteractor, TInteractorProtocol> {
    private var dataSource: UITableDataSource?
    
    @IBOutlet public weak var tableView: UITableView! {
        didSet {
            dataSource = UITableDataSource(actionDelegate: self)
            
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            
            tableView.estimatedSectionFooterHeight = 1
            tableView.estimatedSectionHeaderHeight = 1
            tableView.estimatedRowHeight = 1
            
            tableView.sectionFooterHeight = UITableView.automaticDimension
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.rowHeight = UITableView.automaticDimension
            
            setupTable()
        }
    }
    
    open override func setup(viewModelCenter: ViewModelCenter) {
        viewModelCenter.observe(background: true) { [weak self] (collection: TaggedViewModelCollection) in
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else {
                return
            }
            
            dataSource.append(collection: collection)
            
            DispatchQueue.safeSync {
                // temporarty only
                strongSelf.tableView.reloadData()
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
    
}
