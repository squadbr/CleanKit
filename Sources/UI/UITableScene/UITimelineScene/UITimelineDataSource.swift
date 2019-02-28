//
//  Copyright (c) 2018 Squad
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class UITimelineDataSource: UITableDataSource {
    
    private var isFirstLoad: Bool = true
    private var loadingCount: Int = 0
    
    private var cleanCount: Int = 0
    private var emptyCount: Int = 0
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        self.tableView?.tableFooterView = spinner
        return spinner
    }()
    
    override func clear(force: Bool = false) {
        self.isFirstLoad = true
        super.clear(force: force)
    }
    
    override func insert(collection: TaggedViewModelCollection, at index: Int) -> [IndexPath] {
        self.isFirstLoad = false
        return super.insert(collection: collection, at: index)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        tableView.isUserInteractionEnabled = !self.isFirstLoad
        if self.isFirstLoad && self.sections.isEmpty {
            if self.loadingCount > 0 {
                return 1
            }
        }
        return super.numberOfSections(in: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFirstLoad && self.sections.isEmpty {
            if self.loadingCount > 0 {
                return loadingCount
            } else {
                return self.cleanCount
            }
        } else {
            if self.sections[section]?.items.isEmpty == true {
                return self.emptyCount
            } else {
                return super.tableView(tableView, numberOfRowsInSection: section)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isFirstLoad && self.sections.isEmpty {
            if self.loadingCount > 0 {
                return tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "cleanCell", for: indexPath)
            }
        }
        
        guard let items = self.sections[indexPath.section]?.items else {
            return UITableViewCell()
        }
        if items.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
        } else {
            self.isFirstLoad = false
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row > self.sections.count - self.itemsToPrefetch }) {
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
    
    func setEmptyCell(nib name: String) {
        guard let tableView = self.tableView else { return }
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: "emptyCell")
        self.emptyCount = 1
    }
    
    func setCleanCell(nib name: String) {
        guard let tableView = self.tableView else { return }
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: "cleanCell")
        self.cleanCount = 1
    }
    
}
