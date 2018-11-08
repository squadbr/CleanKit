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

public final class TaggedViewModelCollection: TaggedViewModel {
    lazy var items: [TaggedViewModel] = []
    
    public private(set) var tag: Int
    public var index: Int
    public var animated: Bool
    
    public var count: Int {
        return items.count
    }
    
    public init() {
        self.tag = 0
        self.index = -1
        self.animated = false
    }
    
    public init(tag: Int, index: Int = -1, animated: Bool = false) {
        self.tag = tag
        self.index = index
        self.animated = animated
    }
    
    public subscript(index: Int) -> TaggedViewModel {
        return items[index] 
    }
    
    public func append(item: TaggedViewModel) {
        items.append(item)
    }
}
