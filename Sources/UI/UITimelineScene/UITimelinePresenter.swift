//
//  UITimelinePresenter.swift
//  Squad
//
//  Created by Marcos Kobuchi on 09/10/18.
//  Copyright © 2018 Erwin GO. All rights reserved.
//

import Foundation

open class UITimelinePresenter<TInteractor: UITimelineInteractorProtocol>: Presenter<TInteractor> {
    private var currentPage: Int = 0
    private var hasNext: Bool = true
    private var loading: Bool = false
    private var pageSize: Int = 25
    
    private let lock: NSLock = NSLock()
    
    struct ViewModelItem {
        let identifier: String
        var item: TaggedViewModel
    }
    
    enum Case: Int {
        case load
        case stop
    }
    
    open override func didLoad() {
        self.fetch()
    }
    
    func fetch() {
        DispatchQueue.async {
            guard !self.loading && self.hasNext else { return }
            self.loading = true
            
            do {
                let collection = TaggedViewModelCollection(tag: 1)
                self.currentPage += 1
                
                let objects = try self.interactor.fetch(page: self.currentPage)
                for object in objects {
                    collection.append(item: self.prepare(object: object))
                }
                
                self.hasNext = !(objects.count < self.pageSize)
                self.post(viewModel: collection)
            } catch { }
            
            self.loading = false
        }
    }
    
    open func prepare(object: Any) -> TaggedViewModel {
        preconditionFailure("Should be overwritten.")
    }
    
}
