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

open class UISectionedTableScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: Interactor, TInteractorProtocol> : UIScene<TPresenter, TInteractor, TInteractorProtocol> {
    private var dataSource: UISectionedTableDataSource?
    private var sceneHeader: UITableSceneHeaderProtocol?
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    @IBOutlet public weak var tableView: UITableView! {
        didSet {
            dataSource = UISectionedTableDataSource(actionDelegate: self)
            
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            
            tableView.estimatedSectionFooterHeight = 1
            tableView.estimatedSectionHeaderHeight = 1
            tableView.estimatedRowHeight = 1
            
            tableView.sectionFooterHeight = CGFloat.leastNonzeroMagnitude
            tableView.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
            tableView.rowHeight = UITableView.automaticDimension
            
            setupTable()
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            if height != headerView.frame.height {
                headerView.frame.size.height = height
                self.tableView.tableHeaderView = headerView
                self.tableView.performBatchUpdates({})
            }
        }
    }
    
    open override func setup(actionCenter: ActionCenter) {
        actionCenter.observeAnySectionLoading { [weak self] tag in
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else {
                return
            }
            
            dataSource.updateOrCreate(sectionMessage: nil, forTag: tag)
            
            if let section = dataSource.sectionIndex(forTag: tag), let cell = strongSelf.tableView.cellForRow(at: IndexPath(item: 0, section: section)) as? UITableSceneSectionFeedback {
                cell.prepareLoading()
            }
            
            DispatchQueue.safeSync {
                // temporarty only
                strongSelf.tableView.reloadData()
            }
        }
        
        actionCenter.observeAnySectionMessage { [weak self] tag, message in
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else {
                return
            }
            
            dataSource.updateOrCreate(sectionMessage: message, forTag: tag)
            
            if let section = dataSource.sectionIndex(forTag: tag), let cell = strongSelf.tableView.cellForRow(at: IndexPath(item: 0, section: section)) as? UITableSceneSectionFeedback {
                cell.prepare(message: message)
            }
            
            DispatchQueue.safeSync {
                // temporarty only
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    open override func setup(viewModelCenter: ViewModelCenter) {
        viewModelCenter.observe(background: true) { [weak self] (collection: TaggedViewModelCollection) in
            guard let self = self, let dataSource = self.dataSource else { return }
            
            // temporarty only
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            dataSource.append(collection: collection)
            
            DispatchQueue.safeSync {
                // temporarty only
                self.tableView.reloadData()
            }
        }
    }
    
    public func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        guard let tableView = tableView, let dataSource = dataSource else {
            fatalError("Table has not yet been initialized")
        }
        
        tableView.register(UINib(nibName: "\(cell)", bundle: nil), forCellReuseIdentifier: "\(cell)")
        dataSource.bind(cell: cell, to: viewModel)
    }
    
    public func set<T: UITableSceneHeader<TViewModel>, TViewModel: ViewModel>(header: T.Type) {
        let headerView = T()
        
        tableView.tableHeaderView = headerView
        sceneHeader = headerView
        headerView.delegate = self
        
        presenter.viewModelCenter.observe { [weak self] (viewModel: TViewModel) in
            guard let sceneHeader = self?.sceneHeader else {
                return
            }
            
            sceneHeader.prepare(viewModel: viewModel)
            self?.view.setNeedsLayout()
        }
    }
    
    public func set<T: SectionViewModel>(sectionHeader header: UITableSceneSectionHeader<T>.Type, footer: UITableSceneSectionFooter.Type, feedback: UITableSceneSectionFeedback.Type) {
        guard let tableView = tableView, let dataSource = dataSource else {
            fatalError("Table has not yet been initialized")
        }
        
        dataSource.set(sectionHeader: header, footer: footer, feedback: feedback)
        
        tableView.register(UINib(nibName: "\(footer)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(footer)")
        tableView.register(UINib(nibName: "\(header)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(header)")
        
        tableView.register(UINib(nibName: "\(feedback)", bundle: nil), forCellReuseIdentifier: "\(feedback)")
        
        presenter.viewModelCenter.observe(background: true) { [weak self] (viewModel: T) in
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else {
                return
            }
            
            dataSource.updateOrCreate(sectionViewModel: viewModel)
            
            DispatchQueue.safeSync {
                // temporarty only
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    open func setupTable() {
        assertionFailure("You need to implement the method \"setupTable()\" to prepare this table")
    }
}
