//
//  UITimelineScene.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 09/10/18.
//

import UIKit

open class UITableScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: Interactor, TInteractorProtocol> : UIScene<TPresenter, TInteractor, TInteractorProtocol> {
    
    @IBOutlet public weak var tableView: UITableView! {
        didSet {
//            dataSource = UISectionedTableDataSource(actionDelegate: self)
//
//            tableView.dataSource = dataSource
//            tableView.delegate = dataSource
            
            tableView.estimatedSectionFooterHeight = 1
            tableView.estimatedSectionHeaderHeight = 1
            tableView.estimatedRowHeight = 1
            
            tableView.sectionFooterHeight = UITableView.automaticDimension
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.rowHeight = UITableView.automaticDimension
            
//            setupTable()
        }
    }
    
}
