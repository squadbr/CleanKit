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

import Foundation

protocol TimelinePresenterProtocol {
    func clearOnNextLoad()
    func fetch()
    func update(tag: Int)
}

open class UITimelinePresenter<TInteractor, TEntity>: Presenter<TInteractor>, TimelinePresenterProtocol {
    
    private var timestamp: Date = Date()
    private var currentPage: Int = 0
    private var hasNext: Bool = true
    private var loading: Bool = false
    private var pageSize: Int = 25
    private var objects: [TEntity] = []
    
    public enum UITimelineError: Error {
        case unknown
    }
    
    func clearOnNextLoad() {
        self.currentPage = 0
        self.hasNext = true
        self.loading = false
        self.timestamp = Date()
    }
    
    func update(tag: Int) {
        DispatchQueue.async {
            guard let object = self.find(tag) else { return }
            self.post(action: "update", tag: tag, any: self.prepare(object: object))
        }
    }
    
    public func reload() {
        self.clearOnNextLoad()
        self.fetch()
    }
    
    func fetch() {
        DispatchQueue.async {
            guard !self.loading && self.hasNext else { return }
            self.loading = true
            self.actionCenter.post(action: "load", tag: 0)
            
            do {
                let timestamp = Date()
                let collection = TaggedViewModelCollection(tag: 1)
                let currentPage = self.currentPage + 1
                let objects = try self.fetch(page: currentPage)
                for object in objects {
                    collection.append(item: self.prepare(object: object))
                }
                
                if timestamp < self.timestamp {
                    return
                }
                
                if currentPage == 1 {
                    self.objects = []
                }
                
                self.hasNext = !(objects.count < self.pageSize) || !objects.isEmpty
                self.objects.append(contentsOf: objects)
                self.post(viewModel: collection)
                self.currentPage += 1

            } catch let error {
                debugPrint("\(self.self): \(#function) line: \(#line). \(error.localizedDescription)")
            }
            
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
