//
//  UITimelinePresenter.swift
//  Squad
//
//  Created by Marcos Kobuchi on 09/10/18.
//  Copyright © 2018 Erwin GO. All rights reserved.
//

import Foundation

open class UITimelinePresenter<TInteractor: UITimelineInteractorProtocol>: ParameterizedPresenter<TInteractor, Int> {
    private var pk: Int?
    
    private var reset: Bool = false
    private var currentPage: Int = 0
    private var hasNext: Bool = true
    private var loading: Bool = false
    private var pageSize: Int = 25
    
    struct ViewModelItem {
        let identifier: String
        var item: TaggedViewModel
    }
    
    open override func didLoad(parameter: Int?) {
        self.pk = parameter
        self.fetch()
    }
    
    func clear() {
        self.currentPage = 0
        self.hasNext = true
        self.loading = false
        self.reset = true
    }
    
    func fetch() {
        DispatchQueue.async {
            guard !self.loading && self.hasNext, let pk: Int = self.pk else { return }
            self.loading = true
            
            do {
                let collection = TaggedViewModelCollection(tag: 1)
                
                self.currentPage += 1
                let currentPage = self.currentPage
                
                let objects = try self.interactor.fetch(pk: pk, page: self.currentPage)
                for object in objects {
                    collection.append(item: self.prepare(object: object))
                }
                
                self.hasNext = !(objects.count < self.pageSize)
                
                if !self.reset || currentPage == 1 {
                    self.post(viewModel: collection)
                }
                self.reset = false
            } catch { }
            
            self.loading = false
        }
    }
    
    open func prepare(object: Any) -> TaggedViewModel {
        preconditionFailure("Should be overwritten.")
    }
    
}
