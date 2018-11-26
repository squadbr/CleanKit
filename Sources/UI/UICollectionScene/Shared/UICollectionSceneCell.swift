//
//  UICollectionSceneCell.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 26/11/18.
//

import UIKit

protocol UICollectionSceneCellProtocol: UISceneCellProtocol {
    func prepare(viewModel: ViewModel) -> UICollectionViewCell
}

@IBDesignable
open class UICollectionSceneCell<T: ViewModel>: UICollectionViewCell, UICollectionSceneCellProtocol, ActionDelegate {
    
    weak var delegate: ActionCenterDelegate?
    
    public func post(action name: String) {
        delegate?.actionCenter(postAction: name, tag: tag)
    }
    
    public func post(action name: String, any: Any) {
        delegate?.actionCenter(postAction: name, tag: tag, any: any)
    }
    
    open func prepare(viewModel: T) {
        assertionFailure("You need to implement the method \"prepare(viewModel:)\" to prepare this cell")
    }
    
    func prepare(viewModel: ViewModel) -> UICollectionViewCell {
        guard let cellViewModel = viewModel as? T else {
            fatalError("The \(String(describing: viewModel)) view model is not of the expected \(type(of: T.self)) type")
        }
        
        prepare(viewModel: cellViewModel)
        return self
    }
    
    func focus(bool: Bool) {
    }
    
}
