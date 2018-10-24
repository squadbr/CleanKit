//
//  UITimelineScene.swift
//  Squad
//
//  Created by Marcos Kobuchi on 09/10/18.
//  Copyright © 2018 Erwin GO. All rights reserved.
//

import UIKit

open class UITimelineScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: InteractorProtocol, TInteractorProtocol>: UITableScene<TPresenter, TInteractor, TInteractorProtocol> {
    
    private let activity: UIRefreshControl = UIRefreshControl()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
        
        (presenter as? TimelinePresenterProtocol)?.fetch()
    }
    
    private func setupInterface() {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.refreshControl = self.activity
        self.activity.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc
    private func refresh() {
        self.dataSource?.clear()
        
        (presenter as? TimelinePresenterProtocol)?.clear()
        (presenter as? TimelinePresenterProtocol)?.fetch()
    }
    
    open override func setup(actionCenter: ActionCenter) {
        super.setup(actionCenter: actionCenter)
        actionCenter.observe(action: "prefetch") { [weak self] (_) in
            (self?.presenter as? TimelinePresenterProtocol)?.fetch()
        }
        actionCenter.observe(action: "load") { [weak self] (_) in
            (self?.dataSource as? UITimelineDataSource)?.start()
        }
        actionCenter.observe(action: "stop") { [weak self] (_) in
            (self?.dataSource as? UITimelineDataSource)?.stop()
        }
    }
    
    public var itemsToPrefetch: Int {
        get { return self.dataSource?.itemsToPrefetch ?? 0 }
        set { self.dataSource?.itemsToPrefetch = newValue }
    }
    
    override func loadDataSource() -> UITableDataSource {
        return UITimelineDataSource(tableView: self.tableView, delegate: self)
    }
    
}
