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

class UISectionedTableDataSource : NSObject, UITableViewDataSource, UITableViewDelegate {
    struct ViewModelItem {
        let identifier: String
        var item: TaggedViewModel
    }
    
    struct SectionItem {
        var viewModel: SectionViewModel
        var message: String?
        var items: [ViewModelItem]
    }
    
    private lazy var sections: [Int : SectionItem] = [:]
    private lazy var sectionsIndexes: [Int : Int] = [:]
    private lazy var identifiers: [String : String] = [:]
    
    private var sectionIdentifiers: (header: String, footer: String, feedback: String)?
    private var actionDelegate: ActionCenterDelegate
    
    init(actionDelegate: ActionCenterDelegate) {
        self.actionDelegate = actionDelegate
    }
    
    func append(collection: TaggedViewModelCollection) {
        guard let index = sectionsIndexes[collection.tag], var section = sections[index] else {
            assertionFailure("The section \(collection.tag) tag was not exists")
            return
        }
        
        for item in collection.items {
            let viewModel = "\(type(of: item))"
            
            if let identifier = identifiers[viewModel] {
                section.items.append(ViewModelItem(identifier: identifier, item: item))
            }
            else {
                assertionFailure("The \(viewModel) view model is not binded")
            }
        }
        
        section.message = nil
        sections[index] = section
    }
    
    func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        let current = identifiers["\(viewModel)"]
        
        precondition(current == nil, "The \(viewModel) is binded for \(current!)")
        identifiers["\(viewModel)"] = "\(cell)"
    }
    
    func set<T: SectionViewModel>(sectionHeader header: UITableSceneSectionHeader<T>.Type, footer: UITableSceneSectionFooter.Type, feedback: UITableSceneSectionFeedback.Type) {
        precondition(sectionIdentifiers == nil, "You can not change the existing section footer and header")
        sectionIdentifiers = (header: "\(header)", footer: "\(footer)", feedback: "\(feedback)")
    }
    
    func updateOrCreate(sectionViewModel viewModel: SectionViewModel) {
        let tag = viewModel.tag
        
        if let index = sectionsIndexes[tag] {
            sections[index]!.viewModel = viewModel
        }
        else {
            let index = sections.count
            
            sections[index] = SectionItem(viewModel: viewModel, message: nil, items: [])
            sectionsIndexes[tag] = index
        }
    }
    
    func updateOrCreate(sectionMessage message: String?, forSectionTag tag: Int) {
        if let index = sectionsIndexes[tag] {
            assert(sections[index]?.items.count == 0, "You can not display a message in a section with items")
            sections[index]!.message = message
        }
        else {
            assertionFailure("The section \(tag) tag was not exists")
        }
    }
    
    func index(forSectionTag tag: Int) -> Int? {
        return sectionsIndexes[tag]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = sections[section] else {
            return 0
        }
        
        let count = section.items.count
        return count == 0 && section.viewModel.hasFeedback ? 1 : count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = sections[indexPath.section] else {
            return UITableViewCell(frame: .zero)
        }
        
        guard let item = section.items[safe: indexPath.row] else {
            if indexPath.row == 0 && section.viewModel.hasFeedback {
                if let feedback = sectionIdentifiers?.feedback, let cell = tableView.dequeueReusableCell(withIdentifier: feedback) as? UITableSceneSectionFeedback {
                    if let message = section.message {
                        cell.prepare(message: message)
                    }
                    else {
                        cell.prepareLoading()
                    }
                    
                    return cell
                }
            }
            
            return UITableViewCell(frame: .zero)
        }
        
        if var cell = tableView.dequeueReusableCell(withIdentifier: item.identifier) as? UITableSceneCellProtocol {
            if cell.delegate == nil {
                cell.delegate = actionDelegate
            }
            
            cell.tag = item.item.tag
            return cell.prepare(viewModel: item.item)
        }
        else {
            fatalError("The \(item.identifier) cell is not based on UITableSceneCell")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let sectionIdentifiers = sectionIdentifiers, let section = sections[section], section.viewModel.hasFooter, section.items.count > 0 else {
            return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        }
        
        if let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifiers.footer) as? UITableSceneSectionFooter {
            if footer.delegate == nil {
                footer.delegate = actionDelegate
            }
            
            footer.tag = section.viewModel.tag
            return footer
        }
        
        assertionFailure("The \(sectionIdentifiers.footer) cell is not based on UITableSceneSectionFooter")
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionIdentifiers = sectionIdentifiers, let section = sections[section], (section.items.count > 0 || section.viewModel.hasFeedback) else {
            return nil
        }
        
        if var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifiers.header) as? UITableSceneSectionHeaderProtocol {
            if header.delegate == nil {
                header.delegate = actionDelegate
            }
            
            header.tag = section.viewModel.tag
            return header.prepare(viewModel: section.viewModel)
        }
        
        assertionFailure("The \(sectionIdentifiers.header) cell is not based on UITableSceneSectionHeader")
        return nil
    }
}
