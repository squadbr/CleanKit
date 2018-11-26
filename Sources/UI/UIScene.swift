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

import UIKit

open class UIScene<TPresenter: Presenter<TInteractorProtocol>, TInteractor: InteractorProtocol, TInteractorProtocol>: UIViewController, ActionCenterDelegate {
    public private(set) var presenter: TPresenter!
    
    public init(nibName: String? = nil, interactor: InteractorProtocol = TInteractor(), parameter: Any? = nil) {
        super.init(nibName: nibName, bundle: nil)
        commonInit(interactor: interactor, parameter: parameter)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit(interactor: TInteractor(), parameter: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.async { self.presenter.didLoad() }
    }
    
    open func setup(actionCenter: ActionCenter) {
    }
    
    open func setup(viewModelCenter: ViewModelCenter) {
    }
    
    func commonInit(interactor: InteractorProtocol, parameter: Any?) {
        guard let interactor = interactor as? TInteractorProtocol else {
            fatalError("The interactor protocol informed as an \(type(of: TInteractorProtocol.self)) is not a protocol of the \(type(of: TInteractor.self))")
        }
        
        presenter = TPresenter(interactor: interactor)
        
        if let parameter = parameter {
            guard let parameterizedPresenter = presenter as? ParameterizedPresenterProtocol else {
                fatalError("The \(String(describing: parameter)) parameter is not of the expected ParameterizedPresenter type")
            }
            
            parameterizedPresenter.set(parameter: parameter)
        }
        
        setup(actionCenter: presenter.actionCenter)
        setup(viewModelCenter: presenter.viewModelCenter)
    }
    
    func actionCenter(postAction name: String, tag: Int) {
        presenter.actionCenter.post(action: name, tag: tag)
    }
    
    func actionCenter(postAction name: String, tag: Int, any: Any) {
        presenter.actionCenter.post(action: name, tag: tag, any: any)
    }
    
}
