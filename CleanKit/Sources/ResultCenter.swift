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

public final class ResultCenter {
    private var items = [ObjectIdentifier : Any]()
    
    private var messageExecute: Any?
    private var messageSectionExecute: Any?
    
    public func observe<T: RawRepresentable>(case: T, execute: @escaping(() -> Void)) where T.RawValue == Int {
        let identifier = ObjectIdentifier(T.self)
        
        assert(items[identifier] == nil, "You can not observe the \(type(of: T.self)) more than once")
        items[identifier] = execute
    }
    
    public func observeAnyMessage(execute: @escaping((String) -> Void)) {
        assert(messageExecute == nil, "You can not observe the message more than once")
        messageExecute = execute
    }
    
    public func observeAnySectionMessage(execute: @escaping((Int, String) -> Void)) {
        assert(messageSectionExecute == nil, "You can not observe the section message more than once")
        messageSectionExecute = execute
    }
    
    func post<T: RawRepresentable>(case: T) where T.RawValue == Int {
        if let execute = items[ObjectIdentifier(T.self)] as? () -> Void {
            precondition(!Thread.isMainThread, "You can not access the observer from the main thread")
            
            DispatchQueue.main.async { execute() }
        } else {
            assertionFailure("The \(type(of: T.self)) was not observed")
        }
    }
    
    func post(message: String) {
        if let execute = messageExecute as? (String) -> Void {
            precondition(!Thread.isMainThread, "You can not access the observer from the main thread")
            
            DispatchQueue.main.async { execute(message) }
        } else {
            assertionFailure("The message was not observed")
        }
    }
    
    func post(message: String, forSectionTag tag: Int) {
        if let execute = messageSectionExecute as? (Int, String) -> Void {
            precondition(!Thread.isMainThread, "You can not access the observer from the main thread")
            
            DispatchQueue.main.async { execute(tag, message) }
        } else {
            assertionFailure("The section message was not observed")
        }
    }
}
