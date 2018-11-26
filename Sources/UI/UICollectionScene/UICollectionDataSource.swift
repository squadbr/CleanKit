//
//  UICollectionDataSource.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 26/11/18.
//

import UIKit

public class UICollectionDataSource: NSObject {
    
    private weak var focusedCell: UISceneCellProtocol?
    private(set) weak var collectionView: UICollectionView?
    private(set) weak var delegate: ActionCenterDelegate?
    
    private var reload: Bool = false
    
    internal var items: [ViewModelItem] = []
    private var identifiers: [String: String] = [:]
    
    public init(collectionView: UICollectionView, owner: UIView) {
        self.collectionView = collectionView
        self.delegate = (owner as? UISceneCellProtocol)?.delegate
    }
    
    public func clear() {
        self.reload = true
    }
    
    @discardableResult
    public func append(collection: TaggedViewModelCollection) -> [IndexPath] {
        return self.insert(collection: collection, at: self.items.count)
    }
    
    public func insert(collection: TaggedViewModelCollection, at index: Int) -> [IndexPath] {
        var index: Int = index
        if self.reload {
            self.reload = false
            self.items = []
            index = 0
        }
        
        // indexes of items to be inserted
        var indexesPath: [IndexPath] = []
        
        // process each item
        for (itemIndex, item) in collection.items.enumerated() {
            let viewModel = "\(type(of: item))"
            
            if let identifier = self.identifiers[viewModel] {
                self.items.insert(ViewModelItem(identifier: identifier, item: item), at: itemIndex + index)
            } else {
                assertionFailure("The \(viewModel) view model is not binded")
            }
            
            indexesPath.append(IndexPath(row: itemIndex + index, section: 0))
        }
        
        return indexesPath
    }
    
    public func update(tag: Int, item: TaggedViewModel) {
        guard let index = (self.items.firstIndex { $0.item.tag == tag }) else { return }
        let viewModel = "\(type(of: item))"
        
        if let identifier = self.identifiers[viewModel] {
            self.items[index] = ViewModelItem(identifier: identifier, item: item)
        } else {
            assertionFailure("The \(viewModel) view model is not binded")
        }
        
        self.collectionView?.performBatchUpdates({
            self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
        })
    }
    
    public func remove(tag: Int) {
        guard let index = (self.items.firstIndex { $0.item.tag == tag }) else { return }
        
        self.items.remove(at: index)
        self.collectionView?.performBatchUpdates({
            self.collectionView?.deleteItems(at: [IndexPath(row: index, section: 0)])
        })
    }
    
    public func bind<TCell: UICollectionSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        self.collectionView?.register(UINib(nibName: "\(cell)", bundle: nil), forCellWithReuseIdentifier: "\(cell)")
        let current = identifiers["\(viewModel)"]
        
        precondition(current == nil, "The \(viewModel) is binded for \(current!)")
        identifiers["\(viewModel)"] = "\(cell)"
    }
    
}

extension UICollectionDataSource: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = self.items[safe: indexPath.row] else {
            return UICollectionViewCell(frame: .zero)
        }
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.identifier, for: indexPath) as? UICollectionSceneCellProtocol {
            cell.delegate = delegate
            cell.tag = item.item.tag
            
            return cell.prepare(viewModel: item.item)
        } else {
            fatalError("The \(item.identifier) cell is not based on UICollectionSceneCell")
        }
    }
    
}

extension UICollectionDataSource {
    
    private func focusCell() {
        // unfocus
        self.focusedCell?.focus(bool: false)
        
        // get center
        guard let collectionView = self.collectionView else { return }
        let rect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // get visible cell that is at the center
        
        guard let indexPath = collectionView.indexPathForItem(at: center) else { return }
        for visibleCell in collectionView.visibleCells where collectionView.indexPath(for: visibleCell) == indexPath {
            self.focusedCell = visibleCell as? UISceneCellProtocol
            self.focusedCell?.focus(bool: true)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? UISceneCellProtocol)?.focus(bool: false)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.focusCell()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.focusCell()
    }
    
}

extension UICollectionDataSource: UICollectionViewDataSourcePrefetching {
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    }
    
}
