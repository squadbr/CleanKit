//
//  UITimelinePresenter.swift
//  Squad
//
//  Created by Marcos Kobuchi on 09/10/18.
//  Copyright © 2018 Erwin GO. All rights reserved.
//

import Foundation

protocol TimelinePresenterProtocol {
    func clear()
    func fetch()
    func update(tag: Int)
}

open class UITimelinePresenter<TInteractor, TParameter, TEntity>: ParameterizedPresenter<TInteractor, TParameter>, TimelinePresenterProtocol {
    
    private var reset: Bool = false
    private var currentPage: Int = 0
    private var hasNext: Bool = true
    private var loading: Bool = false
    private var pageSize: Int = 25
    
    private var objects: [TEntity] = []
    
    public enum UITimelineError: Error {
        case unknown
    }
    
    func clear() {
        self.currentPage = 0
        self.hasNext = true
        self.loading = false
        self.reset = true
    }
    
    func update(tag: Int) {
        DispatchQueue.async {
            guard let object = self.find(tag) else { return }
            self.post(action: "update", tag: tag, any: self.prepare(object: object))
        }
    }
    
    func fetch() {
        DispatchQueue.async {
            guard !self.loading && self.hasNext else { return }
            self.loading = true
            self.actionCenter.post(action: "load", tag: 0)
            
            do {
                let collection = TaggedViewModelCollection(tag: 1)
                
                let currentPage = self.currentPage + 1
                let objects = try self.fetch(page: currentPage)
                for object in objects {
                    collection.append(item: self.prepare(object: object))
                }
                
                self.hasNext = !(objects.count < self.pageSize) || !objects.isEmpty
                
                if !self.reset || currentPage == 1 {
                    self.objects.append(contentsOf: objects)
                    self.post(viewModel: collection)
                    self.currentPage += 1
                } else {
                    self.objects = []
                }
                self.reset = false
            } catch { }
            
            self.actionCenter.post(action: "stop", tag: 0)
            self.loading = false
        }
    }
    
    public func find(_ tag: Int) -> TEntity? {
        return self.objects.first(where: { return self.find(tag: tag, object: $0) })
    }
    
    open func find(tag: Int, object: TEntity) -> Bool {
        preconditionFailure("Should be overwritten.")
    }
    
    open func fetch(page: Int) throws -> [TEntity] {
        preconditionFailure("Should be overwritten.")
    }
    
    open func prepare(object: TEntity) -> TaggedViewModel {
        preconditionFailure("Should be overwritten.")
    }
    
}
