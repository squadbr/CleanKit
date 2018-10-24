//
//  TimelineDataSource.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 18/10/18.
//

import UIKit

class UITimelineDataSource: UITableDataSource {
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        self.tableView?.tableFooterView = spinner
        return spinner
    }()
    
    override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row > self.items.count - self.itemsToPrefetch }) {
            delegate?.actionCenter(postAction: "prefetch", tag: 0)
        }
    }
    
    public func start() {
        guard let tableView = self.tableView, self.tableView?.refreshControl?.isRefreshing == false else { return }
        self.spinner.frame.size = CGSize(width: tableView.frame.width, height: 80)
        self.spinner.startAnimating()
    }
    
    public func stop() {
        self.spinner.stopAnimating()
    }
    
}
