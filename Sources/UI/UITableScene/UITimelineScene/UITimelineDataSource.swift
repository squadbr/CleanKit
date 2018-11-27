//
//  TimelineDataSource.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 18/10/18.
//

import UIKit

class UITimelineDataSource: UITableDataSource {
    
    private var isFirstLoad: Bool = true
    private var loadingCount: Int = 0
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        self.tableView?.tableFooterView = spinner
        return spinner
    }()
    
    override func insert(collection: TaggedViewModelCollection, at index: Int) -> [IndexPath] {
        self.isFirstLoad = false
        return super.insert(collection: collection, at: index)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFirstLoad {
            return loadingCount
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isFirstLoad {
            return tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row > self.items.count - self.itemsToPrefetch }) {
            delegate?.actionCenter(postAction: "prefetch", tag: 0)
        }
    }
    
    func start() {
        guard let tableView = self.tableView, self.tableView?.refreshControl?.isRefreshing == false else { return }
        self.spinner.frame.size = CGSize(width: tableView.frame.width, height: 80)
        self.spinner.startAnimating()
    }
    
    func stop() {
        self.spinner.stopAnimating()
    }
    
    func setLoadingCell(nib name: String) {
        guard let tableView = self.tableView else { return }
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: "loadingCell")
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") {
            loadingCount = Int(ceil((tableView.bounds.height / cell.frame.height) + 0.4))
        }
    }
    
}
