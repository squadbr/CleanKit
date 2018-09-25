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

public final class ViewModelCenter {
    private struct Item<T: ViewModel> {
        var background: Bool
        var execute: (T) -> Void
    }
    
    private var items = [ObjectIdentifier : Any]()
    
    public func observe<T: ViewModel>(execute: @escaping((T) -> Void)) {
        observe(background: false, execute: execute)
    }
    
    func observe<T: ViewModel>(background: Bool, execute: @escaping((T) -> Void)) {
        let identifier = ObjectIdentifier(T.self)
        
        assert(items[identifier] == nil, "You can not observe the \(type(of: T.self)) more than once")
        items[identifier] = Item(background: background, execute: execute)
    }
    
    func post<T: ViewModel>(viewModel: T) {
        if let observer = items[ObjectIdentifier(T.self)] as? Item<T> {
            DispatchQueue.safeSync { observer.execute(viewModel) }
        }
        else {
            assertionFailure("The \(type(of: T.self)) was not observed")
        }
    }
}
