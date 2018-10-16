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
//    @IBOutlet private weak var header: UIHeader!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.activity)
        self.tableView.setNeedsLayout()
//        self.tableView.showsVerticalScrollIndicator = false
        self.activity.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc
    private func refresh() {
        self.activity.endRefreshing()
    }
        
    open override func setup(actionCenter: ActionCenter) {
        super.setup(actionCenter: actionCenter)
        actionCenter.observe(case: UITimelinePresenter<UITimelineInteractorProtocol>.Case.load) {
        }
        actionCenter.observe(action: "teste") { (_) in
            self.presenter.fetch()
        }
    }
    
}
