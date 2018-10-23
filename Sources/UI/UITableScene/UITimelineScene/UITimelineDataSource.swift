//
//  TimelineDataSource.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 18/10/18.
//

import UIKit

class UITimelineDataSource: UITableDataSource {
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row > self.items.count - self.itemsToPrefetch }) {
            delegate?.actionCenter(postAction: "prefetch", tag: 0)
            
            self.spinner.frame.size = CGSize(width: tableView.frame.width, height: 80)
            tableView.tableFooterView = self.spinner
            self.spinner.startAnimating()
        }
    }
    
}
