//
//  UITimelineParameterizedPresenter.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 26/11/18.
//

import Foundation

open class UITimelineParameterizedPresenter<TInteractor, TParameter, TEntity>: UITimelinePresenter<TInteractor, TEntity>, ParameterizedPresenterProtocol {
    
    private var parameter: TParameter?
    
    open override func didLoad() {
        didLoad(parameter: self.parameter)
    }
    
    open func didLoad(parameter: TParameter?) {
        assertionFailure("You need to implement the method \"didLoad(parameter:)\" to load this presenter")
    }
    
    public func set(parameter: Any) {
        guard let newParameter = parameter as? TParameter else {
            fatalError("The \(String(describing: parameter)) parameter is not of the expected \(type(of: TParameter.self)) type")
        }
        
        guard self.parameter == nil else {
            fatalError("The parameter should be set only one time!")
        }
        
        self.parameter = newParameter
    }
    
}
