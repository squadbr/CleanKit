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

open class Presenter<TInteractor> {
    private let presenterInteractor: TInteractor
    
    let resultCenter = ResultCenter()
    let viewModelCenter = ViewModelCenter()
    
    public var interactor: TInteractor {
        get {
            precondition(!Thread.isMainThread, "You can not access the interactor from the main thread")
            return presenterInteractor
        }
    }
    
    public required init(interactor: TInteractor) {
        self.presenterInteractor = interactor
    }
    
    public func post<T: ViewModel>(viewModel: T) {
        viewModelCenter.post(viewModel: viewModel)
    }
    
    public func post<T: TaggedViewModelCollection>(collection: T, emptyMessage message: String? = nil) {
        if collection.count > 0 {
            viewModelCenter.post(viewModel: collection)
        }
        else if let message = message {
            resultCenter.post(message: message, forSectionTag: collection.tag)
        }
    }
    
    public func post<T: RawRepresentable>(case: T) where T.RawValue == Int {
        resultCenter.post(case: `case`)
    }
    
    public func post(message: String) {
        resultCenter.post(message: message)
    }
    
    public func post(message: String, forSectionTag tag: Int) {
        resultCenter.post(message: message, forSectionTag: tag)
    }
    
    open func didLoad() {
    }
}
