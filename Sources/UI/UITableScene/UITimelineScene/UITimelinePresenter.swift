//
//  UITimelinePresenter.swift
//  Squad
//
//  Created by Marcos Kobuchi on 09/10/18.
//  Copyright © 2018 Erwin GO. All rights reserved.
//

import Foundation

open class UITimelinePresenter<TInteractor: InteractorProtocol, TEntity>: ParameterizedPresenter<TInteractor, Int> {
    
    private var reset: Bool = false
    private var currentPage: Int = 0
    private var hasNext: Bool = true
    private var loading: Bool = false
    private var pageSize: Int = 25
    
    public enum UITimelineError: Error {
        case unknown
    }
    
    func clear() {
        self.currentPage = 0
        self.hasNext = true
        self.loading = false
        self.reset = true
    }
    
    func fetch() {
        DispatchQueue.async {
            guard !self.loading && self.hasNext else { return }
            self.loading = true
            
            do {
                let collection = TaggedViewModelCollection(tag: 1)
                
                self.currentPage += 1
                let currentPage = self.currentPage
                
                let objects = try self.fetch(page: self.currentPage)
                for object in objects {
                    collection.append(item: self.prepare(object: object))
                }
                
                self.hasNext = !(objects.count < self.pageSize) || !objects.isEmpty
                
                if !self.reset || currentPage == 1 {
                    self.post(viewModel: collection)
                }
                self.reset = false
            } catch { }
            
            self.loading = false
        }
    }
    
    open func fetch(page: Int) throws -> [TEntity] {
        preconditionFailure("Should be overwritten.")
    }
    
    open func prepare(object: TEntity) -> TaggedViewModel {
        preconditionFailure("Should be overwritten.")
    }
    
}
