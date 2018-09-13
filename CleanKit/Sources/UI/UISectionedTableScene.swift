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

open class UISectionedTableScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: Interactor, TInteractorProtocol> : UIScene<TPresenter, TInteractor, TInteractorProtocol>, ActionCenterDelegate {
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
            
            tableView.sectionFooterHeight = UITableViewAutomaticDimension
            tableView.sectionHeaderHeight = UITableViewAutomaticDimension
            tableView.rowHeight = UITableViewAutomaticDimension
            
            setup()
        }
    }
    
    open override func setup(viewModelCenter: ViewModelCenter, actionCenter: ActionCenter) {
        viewModelCenter.observe(background: true) { [weak self] (collection: TaggedViewModelCollection) in
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else {
                return
            }
            
            strongSelf.semaphore.wait()
            defer { strongSelf.semaphore.signal() }
            
            dataSource.append(collection: collection)
            
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    public func register<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, viewModel: TViewModel.Type) {
        guard let tableView = tableView, let dataSource = dataSource else {
            fatalError("Table has not yet been initialized")
        }
        
        tableView.register(UINib(nibName: "\(cell)", bundle: nil), forCellReuseIdentifier: "\(cell)")
        dataSource.register(cell: cell, viewModel: viewModel)
    }
    
    public func set<T: UITableSceneHeader<TViewModel>, TViewModel: ViewModel>(header: T.Type) {
        sceneHeader = T()
        
        tableView.tableHeaderView = sceneHeader!.contentView
        
        //tableView.setAndLayout(headerView: sceneHeader!.contentView)
        
        presenter.viewModelCenter.observe { [weak self] (viewModel: TViewModel) in
            guard let sceneHeader = self?.sceneHeader else {
                return
            }
            
            sceneHeader.prepare(viewModel: viewModel)
        }
    }
    
    public func set<T: SectionHeaderViewModel>(sectionHeader header: UITableSceneSectionHeader<T>.Type, footer: UITableSceneSectionFooter.Type) {
        guard let tableView = tableView, let dataSource = dataSource else {
            fatalError("Table has not yet been initialized")
        }
        
        tableView.register(UINib(nibName: "\(footer)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(footer)")
        tableView.register(UINib(nibName: "\(header)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(header)")
        
        dataSource.set(sectionHeader: header, footer: footer)
        
        presenter.viewModelCenter.observe(background: true) { [weak self] (viewModel: T) in
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else {
                return
            }
            
            dataSource.updateOrCreate(sectionViewModel: viewModel)
            
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    public func observe(action name: String, execute: @escaping((_ tag: Int) -> Void)) {
        super.actionCenter.observe(action: name, execute: execute)
    }
    
    open func setup() {
        assertionFailure("You need to implement the method \"setup()\" to prepare this table")
    }
    
    func actionCenter(postAction name: String, tag: Int) {
        super.actionCenter.post(action: name, tag: tag)
    }
}
