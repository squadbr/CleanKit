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

protocol UITableSceneCellProtocol: class {
    var delegate: ActionCenterDelegate? { get set }
    var tag: Int { get set }
    
    func prepare(viewModel: ViewModel) -> UITableViewCell
    func focus(bool: Bool)
}

@IBDesignable
open class UITableSceneCell<T: ViewModel>: UITableViewCell, UITableSceneCellProtocol, ActionDelegate {
    weak var delegate: ActionCenterDelegate?
    
    @IBInspectable public var touchActionName: String?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .nonebool
        focusStyle = .custom
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        
        tapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapRecognizer)
    }
    
    public func post(action name: String) {
        delegate?.actionCenter(postAction: name, tag: tag)
    }
    
    public func post(action name: String, any: Any) {
        delegate?.actionCenter(postAction: name, tag: tag, any: any)
    }
    
    open func prepare(viewModel: T) {
        assertionFailure("You need to implement the method \"prepare(viewModel:)\" to prepare this cell")
    }
    
    func prepare(viewModel: ViewModel) -> UITableViewCell {
        guard let cellViewModel = viewModel as? T else {
            fatalError("The \(String(describing: viewModel)) view model is not of the expected \(type(of: T.self)) type")
        }
        
        prepare(viewModel: cellViewModel)
        return self
    }
    
    @objc fileprivate func didTap() {
        guard let touchActionName = touchActionName else {
            return
        }
        
        delegate?.actionCenter(postAction: touchActionName, tag: tag)
    }
    
    func focus(bool: Bool) {
    }
    
}
