//
//  UITableDataSource.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 09/10/18.
//

import UIKit

class UITableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    struct ViewModelItem {
        let identifier: String
        var item: TaggedViewModel
    }
    
    struct SectionItem {
        var viewModel: SectionViewModel
        var message: String?
        var items: [ViewModelItem]
    }
    
    private var actionDelegate: ActionCenterDelegate
    private lazy var items: [ViewModelItem] = []
    private lazy var identifiers: [String: String] = [:]
    
    init(actionDelegate: ActionCenterDelegate) {
        self.actionDelegate = actionDelegate
    }
    
    func append(collection: TaggedViewModelCollection) {
        for item in collection.items {
            let viewModel = "\(type(of: item))"
            
            if let identifier = identifiers[viewModel] {
                self.items.append(ViewModelItem(identifier: identifier, item: item))
            } else {
                assertionFailure("The \(viewModel) view model is not binded")
            }
        }
    }
    
    func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        let current = identifiers["\(viewModel)"]
        
        precondition(current == nil, "The \(viewModel) is binded for \(current!)")
        identifiers["\(viewModel)"] = "\(cell)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.isEmpty ? 0 : self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = self.items[safe: indexPath.row] else {
            return UITableViewCell(frame: .zero)
        }
        
        if var cell = tableView.dequeueReusableCell(withIdentifier: item.identifier) as? UITableSceneCellProtocol {
            cell.delegate = actionDelegate
            cell.tag = item.item.tag
            
            return cell.prepare(viewModel: item.item)
        } else {
            fatalError("The \(item.identifier) cell is not based on UITableSceneCell")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height - 300 < scrollView.contentOffset.y {
            NotificationCenter.default.post(name: NSNotification.Name("blablabla"), object: nil)
        }
    }
    
}
