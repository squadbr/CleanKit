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

open class UITimelineScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: InteractorProtocol, TInteractorProtocol>: UITableScene<TPresenter, TInteractor, TInteractorProtocol> {
    
    private let activity: UIRefreshControl = UIRefreshControl()
    private var _presenter: TimelinePresenterProtocol!
    
    private(set) open var shouldFetchOnLoad: Bool = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
        
        guard let presenter = self.presenter as? TimelinePresenterProtocol else {
            preconditionFailure("presenter should implement timeline presenter")
        }
        self._presenter = presenter
        if self.shouldFetchOnLoad { presenter.fetch() }
    }
    
    private func setupInterface() {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.refreshControl = self.activity
        self.activity.addTarget(self, action: #selector(refresh as () -> Void), for: .valueChanged)
    }
    
    @objc
    open func refresh() {
        self.dataSource?.clear()
        self._presenter.clearOnNextLoad()
        self._presenter.fetch()
    }
    
    public func refresh(tag: Int) {
        self._presenter.update(tag: tag)
    }
    
    public func clear() {
        self.dataSource?.clear(force: true)
        self._presenter.clearOnNextLoad()
        self.tableView.reloadData()
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
    
    public func setLoadingCell(nib name: String) {
        (self.dataSource as? UITimelineDataSource)?.setLoadingCell(nib: name)
    }
    
    public func setEmptyCell(nib name: String) {
        (self.dataSource as? UITimelineDataSource)?.setEmptyCell(nib: name)
    }
    
    public func setCleanCell(nib name: String) {
        (self.dataSource as? UITimelineDataSource)?.setCleanCell(nib: name)
    }
    
}
