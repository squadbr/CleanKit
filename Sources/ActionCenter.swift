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

public final class ActionCenter {
    private lazy var items = [String: Any]()
    private lazy var caseItems = [ObjectIdentifier: Any]()
    
    private var messageExecute: Any?
    private var sectionLoadingExecute: Any?
    private var sectionMessageExecute: Any?
    
    public func observe(action name: String, execute: @escaping((_ tag: Int) -> Void)) {
        assert(items[name] == nil, "The \(name) action already exists")
        items[name] = execute
    }
    
    public func observe(action name: String, execute: @escaping((_ tag: Int, _ any: Any) -> Void)) {
        assert(items[name] == nil, "The \(name) action already exists")
        items[name] = execute
    }
    
    public func observe<T: RawRepresentable>(case: T, execute: @escaping(() -> Void)) {
        let identifier = ObjectIdentifier(`case`.rawValue as AnyObject)
        assert(caseItems[identifier] == nil, "You can not observe the \(type(of: T.self)) more than once")
        caseItems[identifier] = execute
    }
    
    public func observe<T: RawRepresentable>(case: T, execute: @escaping((Any) -> Void)) {
        let identifier = ObjectIdentifier(`case`.rawValue as AnyObject)
        assert(caseItems[identifier] == nil, "You can not observe the \(type(of: T.self)) more than once")
        caseItems[identifier] = execute
    }
    
    public func observeAnyMessage(execute: @escaping((String) -> Void)) {
        assert(messageExecute == nil, "You can not observe the any message more than once")
        messageExecute = execute
    }
    
    public func observeAnySectionLoading(execute: @escaping((Int) -> Void)) {
        assert(sectionLoadingExecute == nil, "You can not observe the any section loading more than once")
        sectionLoadingExecute = execute
    }
    
    public func observeAnySectionMessage(execute: @escaping((Int, String) -> Void)) {
        assert(sectionMessageExecute == nil, "You can not observe the any section message more than once")
        sectionMessageExecute = execute
    }
    
    func post(action name: String, tag: Int) {
        if let execute = items[name] as? ((Int) -> Void) {
            DispatchQueue.safeSync { execute(tag) }
        } else {
            assertionFailure("The \(name) action does not exist")
        }
    }
    
    func post(action name: String, tag: Int, any: Any) {
        if let execute = items[name] as? (Int, Any) -> Void {
            DispatchQueue.safeSync { execute(tag, any) }
        } else {
            assertionFailure("The \(name) action does not exist")
        }
    }
    
    func post<T: RawRepresentable>(case: T) {
        if let execute = caseItems[ObjectIdentifier(`case`.rawValue as AnyObject)] as? () -> Void {
            DispatchQueue.safeSync { execute() }
        } else {
            assertionFailure("The \(type(of: T.self)) was not observed")
        }
    }
    
    func post<T: RawRepresentable>(case: T, any: Any) {
        if let execute = caseItems[ObjectIdentifier(`case`.rawValue as AnyObject)] as? (Any) -> Void {
            DispatchQueue.safeSync { execute(any) }
        } else {
            assertionFailure("The \(type(of: T.self)) was not observed")
        }
    }
    
    func post(message: String) {
        if let execute = messageExecute as? (String) -> Void {
            DispatchQueue.safeSync { execute(message) }
        } else {
            assertionFailure("The message was not observed")
        }
    }
    
    func post(sectionLoadingForTag tag: Int) {
        if let execute = sectionLoadingExecute as? (Int) -> Void {
            DispatchQueue.safeSync { execute(tag) }
        } else {
            assertionFailure("The section loading was not observed")
        }
    }
    
    func post(sectionMessage message: String, forTag tag: Int) {
        if let execute = sectionMessageExecute as? (Int, String) -> Void {
            DispatchQueue.safeSync { execute(tag, message) }
        } else {
            assertionFailure("The section message was not observed")
        }
    }
}
