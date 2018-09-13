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

protocol UITableSceneHeaderProtocol {
    var delegate: ActionCenterDelegate? { get set }
    var contentView: UIView! { get }
    
    func prepare(viewModel: ViewModel)
}

open class UITableSceneHeader<T: ViewModel> : UIView, UITableSceneHeaderProtocol {
    var delegate: ActionCenterDelegate?
    
    @IBOutlet public weak var contentView: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func post(action name: String) {
        delegate?.actionCenter(postAction: name, tag: tag)
    }
    
    open func prepare(viewModel: T) {
        assertionFailure("You need to implement the method \"prepare(viewModel:)\" to prepare this section header")
    }
    
    func prepare(viewModel: ViewModel) {
        guard let headerViewModel = viewModel as? T else {
            fatalError("The \(String(describing: viewModel)) view model is not of the expected \(type(of: T.self)) type")
        }
        
        prepare(viewModel: headerViewModel)
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("\(type(of: self))", owner: self, options: nil)
        addSubview(contentView)
    }
}
