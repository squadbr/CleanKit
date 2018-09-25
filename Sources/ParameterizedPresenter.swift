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

protocol ParameterizedPresenterProtocol {
    func set(parameter: Any)
}

open class ParameterizedPresenter<TInteractor, TParameter> : Presenter<TInteractor>, ParameterizedPresenterProtocol {
    private var parameter: TParameter?
    
    open override func didLoad() {
        guard let parameter = parameter else {
            fatalError("Parameter has not yet been initialized")
        }
        
        didLoad(parameter: parameter)
    }
    
    open func didLoad(parameter: TParameter) {
        assertionFailure("You need to implement the method \"didLoad(parameter:)\" to load this presenter")
    }
    
    func set(parameter: Any) {
        guard let newParameter = parameter as? TParameter else {
            fatalError("The \(String(describing: parameter)) parameter is not of the expected \(type(of: TParameter.self)) type")
        }
        
        self.parameter = newParameter
    }
}
