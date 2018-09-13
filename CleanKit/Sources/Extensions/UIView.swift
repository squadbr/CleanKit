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

extension UIView {
    func loadFromNib() {
        let contentView = UINib(nibName: "\(type(of: self))", bundle: Bundle(for: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
        
        insertSubview(contentView, at: 0)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(0)).isActive = true
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: CGFloat(0)).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: CGFloat(0)).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: CGFloat(0)).isActive = true
    }
}
