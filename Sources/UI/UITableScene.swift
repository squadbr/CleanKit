//
//  UITimelineScene.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 09/10/18.
//

import UIKit

open class UITableScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: Interactor, TInteractorProtocol> : UIScene<TPresenter, TInteractor, TInteractorProtocol> {
    var dataSource: UITableDataSource?
    
    @IBOutlet public weak var tableView: UITableView! {
        didSet {
            dataSource = UITableDataSource(tableView: self.tableView, delegate: self)
            
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            tableView.prefetchDataSource = dataSource
            
            tableView.estimatedSectionFooterHeight = 1
            tableView.estimatedSectionHeaderHeight = 1
            tableView.estimatedRowHeight = UITableView.automaticDimension
            
            tableView.sectionFooterHeight = UITableView.automaticDimension
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.rowHeight = UITableView.automaticDimension
            
            setupTable()
        }
    }
    
    open override func setup(viewModelCenter: ViewModelCenter) {
        viewModelCenter.observe(background: true) { [weak self] (collection: TaggedViewModelCollection) in
            guard let self = self, let dataSource = self.dataSource else { return }
            dataSource.append(collection: collection)
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
