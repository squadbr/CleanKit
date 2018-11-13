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
    private var _presenter: TimelinePresenterProtocol!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
        
        guard let presenter = self.presenter as? TimelinePresenterProtocol else {
            preconditionFailure("presenter should implement timeline presenter")
        }
        self._presenter = presenter
        presenter.fetch()
    }
    
    private func setupInterface() {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.refreshControl = self.activity
        self.activity.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc
    open func refresh() {
        self.dataSource?.clear()
        
        _presenter.clear()
        _presenter.fetch()
    }
    
    open override func setup(actionCenter: ActionCenter) {
        super.setup(actionCenter: actionCenter)
        actionCenter.observe(action: "prefetch") { [weak self] (_) in
            (self?._presenter)?.fetch()
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
