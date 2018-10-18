//
//  UITimelineScene.swift
//  Squad
//
//  Created by Marcos Kobuchi on 09/10/18.
//  Copyright © 2018 Erwin GO. All rights reserved.
//

import UIKit

open class UITimelineScene<TPresenter: UITimelinePresenter<UITimelineInteractorProtocol>, TInteractor: Interactor, UITimelineInteractorProtocol>: UITableScene<TPresenter, TInteractor, UITimelineInteractorProtocol> {
    
    private let activity: UIRefreshControl = UIRefreshControl()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
    
    private func setupInterface() {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.refreshControl = self.activity
        self.activity.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc
    private func refresh() {
        self.dataSource?.clear()
        self.presenter.clear()
        self.presenter.fetch()
    }
    
    open override func setup(actionCenter: ActionCenter) {
        super.setup(actionCenter: actionCenter)
        actionCenter.observe(action: "prefetch") { (_) in
            self.presenter.fetch()
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
