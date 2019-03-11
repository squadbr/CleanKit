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

class UITableDataSource: NSObject {
    
    class SectionItem {
        var viewModel: SectionViewModel
        var items: [(viewModel: ViewModelItem, cellState: CellState?)]
        
        init(viewModel: SectionViewModel, items: [(viewModel: ViewModelItem, cellState: CellState?)]) {
            self.viewModel = viewModel
            self.items = items
        }
    }
    
    private weak var focusedCell: UITableSceneCellProtocol?
    private(set) weak var tableView: UITableView?
    private(set) weak var delegate: ActionCenterDelegate?
    
    private var reload: Bool = false
    
    private var sectionIdentifiers: (header: String, footer: String, feedback: String)?
    private(set) var sections: [Int: SectionItem] = [:]
    private var sectionsIndexes: [Int: Int] = [:]
    
    private var identifiers: [String: String] = [:]
    private var heights: [IndexPath: CGFloat] = [:]
    
    private var isFirstLoad: Bool = true
    private var emptyCount: Int = 0
    private var cleanCount: Int = 0
    private var loadingCount: Int = 0
    
    private var backgroundColor: UIColor?
    
    internal var itemsToPrefetch: Int = 50
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        self.tableView?.tableFooterView = spinner
        return spinner
    }()
    
    init(tableView: UITableView, delegate: ActionCenterDelegate) {
        self.tableView = tableView
        self.delegate = delegate
    }
    
    func clear(force: Bool = false) {
        self.isFirstLoad = true
        self.reload = true
        if force {
            for (_, section) in self.sections {
                section.items = []
            }
        }
    }
    
    func append(collection: TaggedViewModelCollection) -> [IndexPath] {
        self.isFirstLoad = false
        let section = self.section(for: collection.tag)
        return self.insert(collection: collection, at: section.item.items.count)
    }
    
    func insert(collection: TaggedViewModelCollection, at index: Int) -> [IndexPath] {
        self.isFirstLoad = false
        var index: Int = index
        if self.reload {
            self.reload = false
            for (_, section) in self.sections {
                section.items = []
            }
            index = 0
        }
        
        let section = self.section(for: collection.tag)
        
        // indexes of items to be inserted
        var indexesPath: [IndexPath] = []
        
        // process each item
        for (itemIndex, item) in collection.items.enumerated() {
            let viewModel = "\(type(of: item))"
            
            if let identifier = self.identifiers[viewModel] {
                section.item.items.insert((ViewModelItem(identifier: identifier, item: item), nil), at: itemIndex + index)
            } else {
                assertionFailure("The \(viewModel) view model is not binded")
            }
            
            indexesPath.append(IndexPath(row: itemIndex + index, section: section.index))
        }
        
        return indexesPath
    }
    
    func update(tag: Int, item: TaggedViewModel) {
        guard let indexPath: IndexPath = self.find(tag: tag) else { return }
        let viewModel = "\(type(of: item))"
        
        if let identifier = self.identifiers[viewModel] {
            self.sections[indexPath.section]?.items[indexPath.row] = (ViewModelItem(identifier: identifier, item: item), nil)
        } else {
            assertionFailure("The \(viewModel) view model is not binded")
        }
        
        self.tableView?.reloadData()
    }
    
    func remove(tag: Int) {
        guard let indexPath: IndexPath = self.find(tag: tag) else { return }
        self.sections[indexPath.section]?.items.remove(at: indexPath.row)
        self.tableView?.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func bind<TCell: UITableSceneCell<TViewModel>, TViewModel: TaggedViewModel>(cell: TCell.Type, to viewModel: TViewModel.Type) {
        self.tableView?.register(UINib(nibName: "\(cell)", bundle: nil), forCellReuseIdentifier: "\(cell)")
        let current = identifiers["\(viewModel)"]
        precondition(current == nil, "The \(viewModel) is binded for \(current!)")
        self.identifiers["\(viewModel)"] = "\(cell)"
    }
    
    func set<T: SectionViewModel>(sectionHeader header: UITableSceneSectionHeader<T>.Type, footer: UITableSceneSectionFooter.Type? = nil, feedback: UITableSceneSectionFeedback.Type? = nil) {
        precondition(self.sectionIdentifiers == nil, "You can not change the existing section footer and header")
        self.tableView?.register(UINib(nibName: "\(header)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(header)")
        
        var footerIdentifier = ""
        var feedbackIdentifier = ""
        
        if let unwrapedFooter = footer {
            self.tableView?.register(UINib(nibName: "\(unwrapedFooter)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(unwrapedFooter)")
            footerIdentifier = "\(unwrapedFooter)"
        }
        
        if let unwrapedFeedback = feedback {
            self.tableView?.register(UINib(nibName: "\(unwrapedFeedback)", bundle: nil), forCellReuseIdentifier: "\(unwrapedFeedback)")
            feedbackIdentifier = "\(unwrapedFeedback)"
        }
        
        self.sectionIdentifiers = (header: "\(header)", footer: footerIdentifier, feedback: feedbackIdentifier)
    }
    
    func updateOrCreate(sectionViewModel viewModel: SectionViewModel) {
        let tag: Int = viewModel.tag
        
        if let index = self.sectionsIndexes[tag] {
            self.sections[index]?.viewModel = viewModel
        } else {
            let index = sections.count
            self.sections[index] = SectionItem(viewModel: viewModel, items: [])
            self.sectionsIndexes[tag] = index
        }
    }
    
    func setEmptyCell(nib name: String) {
        guard let tableView = self.tableView else { return }
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: "emptyCell")
        self.emptyCount = 1
        self.backgroundColor = tableView.backgroundColor
    }
    
    func setCleanCell(nib name: String) {
        guard let tableView = self.tableView else { return }
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: "cleanCell")
        self.cleanCount = 1
        self.backgroundColor = tableView.backgroundColor
    }
    
    func setLoadingCell(nib name: String) {
        guard let tableView = self.tableView else { return }
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: "loadingCell")
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") {
            loadingCount = Int(ceil((tableView.bounds.height / cell.frame.height) + 0.4))
        }
        self.backgroundColor = tableView.backgroundColor
    }
    
    private func isDataSourceEmpty() -> Bool {
        var shouldShowEmptyState: Bool = true
        for section in self.sections where !section.value.items.isEmpty {
            shouldShowEmptyState = false
            break
        }
        return shouldShowEmptyState
    }
    
    func start() {
        guard let tableView = self.tableView, self.tableView?.refreshControl?.isRefreshing == false else { return }
        self.spinner.frame.size = CGSize(width: tableView.frame.width, height: 80)
        self.spinner.startAnimating()
    }
    
    func stop() {
        self.spinner.stopAnimating()
    }
}

extension UITableDataSource: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        tableView.isUserInteractionEnabled = !self.isFirstLoad
        if self.isFirstLoad {
            if self.loadingCount > 0 {
                return 1
            } else if self.cleanCount > 0 {
                return 1
            }
        }
        if self.isDataSourceEmpty() && self.emptyCount > 0 {
            return 1
        }
        
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isFirstLoad {
            if self.loadingCount > 0 {
                return loadingCount
            } else if self.cleanCount > 0 {
                return self.cleanCount
            }
        }
        if self.isDataSourceEmpty() && self.emptyCount > 0 {
            return self.emptyCount
        }
        
        guard let section = sections[section] else {
            return 0
        }
    
        return section.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isFirstLoad {
            if self.loadingCount > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
                tableView.backgroundColor = cell.backgroundColor
                return cell
            } else if self.cleanCount > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cleanCell", for: indexPath)
                tableView.backgroundColor = cell.backgroundColor
                return cell
            }
        }
        
        if self.isDataSourceEmpty() && self.emptyCount > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            tableView.backgroundColor = cell.backgroundColor
            return cell
        }
        
        tableView.backgroundColor = self.backgroundColor ?? tableView.backgroundColor
        
        guard let item = sections[indexPath.section]?.items[safe: indexPath.row] else {
            return UITableViewCell(frame: .zero)
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: item.viewModel.identifier, for: indexPath) as? UITableSceneCellProtocol {
            cell.delegate = delegate
            cell.tag = item.viewModel.item.tag
            
            let tableCell: UITableViewCell = cell.prepare(viewModel: item.viewModel.item)
            if let state = item.cellState {
                cell.restore(state)
            }
            
            return tableCell
        }
        
        assertionFailure("The \(item.viewModel.identifier) cell is not based on UITableSceneCell")
        return UITableViewCell(frame: .zero)
    }
    
    // functions to calculate height
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.heights[indexPath] = cell.bounds.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heights[indexPath] ?? UITableView.automaticDimension
    }
    
}

extension UITableDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = self.sections[section], section.viewModel.hasHeader, !section.items.isEmpty else {
            return CGFloat.leastNonzeroMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = self.sections[section], section.viewModel.hasHeader, !section.items.isEmpty, let sectionIdentifiers = self.sectionIdentifiers else {
            return nil
        }
        
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifiers.header) as? UITableSceneSectionHeaderProtocol {
            header.delegate = self.delegate
            header.tag = section.viewModel.tag
            
            return header.prepare(viewModel: section.viewModel)
        }
        
        assertionFailure("The \(sectionIdentifiers.header) cell is not based on UITableSceneSectionHeader")
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        guard let section = self.sections[section], section.viewModel.hasFooter, !section.items.isEmpty else {
            return CGFloat.leastNonzeroMagnitude
            //tableView.sectionFooterHeight
        }
        return tableView.sectionFooterHeight
        //return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let sectionIdentifiers = sectionIdentifiers, let section = sections[section], section.viewModel.hasFooter, !section.items.isEmpty else {
            return nil
        }
        
        if let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifiers.footer) as? UITableSceneSectionFooter {
            footer.delegate = self.delegate
            footer.tag = section.viewModel.tag
            
            return footer
        }
        
        assertionFailure("The \(sectionIdentifiers.footer) cell is not based on UITableSceneSectionFooter")
        return UIView(frame: .zero)
    }
}

extension UITableDataSource {
    
    private func focusCell() {
        // unfocus
        self.focusedCell?.focus(bool: false)
        
        // get center
        guard let tableView = self.tableView else { return }
        let rect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // get visible cell that is at the center
        guard let indexPath = tableView.indexPathForRow(at: center) else { return }
        for visibleCell in tableView.visibleCells where tableView.indexPath(for: visibleCell) == indexPath {
            self.focusedCell = visibleCell as? UITableSceneCellProtocol
            self.focusedCell?.focus(bool: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? UITableSceneCellProtocol else { return }
        cell.focus(bool: false)
        guard self.sections[indexPath.section]?.items.count ?? 0 > indexPath.row else { return }
        self.sections[indexPath.section]?.items[indexPath.row].cellState = cell.save()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.focusCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.focusCell()
    }
    
}

// MARK: - utils
extension UITableDataSource {
    
    private func section(for tag: Int) -> (index: Int, item: SectionItem) {
        if let sectionIndex = sectionsIndexes[tag], let section = self.sections[sectionIndex] {
            return (sectionIndex, section)
        }
        let index = self.sections.count
        let section = SectionItem(viewModel: SectionDefault(tag: tag), items: [])
        sections[index] = section
        sectionsIndexes[tag] = index
        return (index, section)
    }
    
    private func find(tag: Int) -> IndexPath? {
        var sectionIndex: Int?
        var rowIndex: Int?
        for (currentSection, section) in self.sections {
            guard let currentRow = section.items.firstIndex(where: { $0.viewModel.item.tag == tag }) else { continue }
            sectionIndex = currentSection
            rowIndex = currentRow
            break
        }
        
        guard let sectionIndex2 = sectionIndex, let rowIndex2 = rowIndex else {
            return nil
        }
        
        return IndexPath(row: rowIndex2, section: sectionIndex2)
    }
    
}

extension UITableDataSource: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }
    
}
