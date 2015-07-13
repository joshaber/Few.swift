//
//  TableView.swift
//  Few
//
//  Created by Coen Wessels on 13-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private let defaultRowHeight: CGFloat = 42

private class FewTableHeaderFooter: UIView {
	var didChangeHeight: (FewTableHeaderFooter -> Void)?
	private lazy var parentElement: RealizedElement = {[unowned self] in
		return RealizedElement(element: Element(), view: self.contentView, parent: nil)
	}()
	
	private(set) lazy var contentView: UIView = {[unowned self] in
		let v = UIView(frame: self.bounds)
		configureViewToAutoresize(v)
		self.addSubview(v)
		return v
	}()
	
	private var realizedElement: RealizedElement?
	
	func updateWithElement(element: Element) {
		if let oldRealizedElement = realizedElement {
			if element.canDiff(oldRealizedElement.element) {
				element.applyDiff(oldRealizedElement.element, realizedSelf: oldRealizedElement)
			} else {
				oldRealizedElement.remove()
				
				realizedElement = element.realize(parentElement)
			}
		} else {
			realizedElement = element.realize(parentElement)
		}
		
		realizedElement?.layoutFromRoot()
		let layout = element.assembleLayoutNode().layout(maxWidth: bounds.width)
		let oldHeight = bounds.height
		layout.apply(contentView)

		if contentView.frame.height != oldHeight {
			bounds.size.height = contentView.frame.height
			didChangeHeight?(self)
		}
	}
}

private class FewSectionHeaderFooter: UITableViewHeaderFooterView {
	private lazy var parentElement: RealizedElement = {[unowned self] in
		return RealizedElement(element: Element(), view: self.contentView, parent: nil)
	}()
	private var realizedElement: RealizedElement?
	
	func updateWithElement(element: Element) {
		if let oldRealizedElement = realizedElement {
			if element.canDiff(oldRealizedElement.element) {
				element.applyDiff(oldRealizedElement.element, realizedSelf: oldRealizedElement)
			} else {
				oldRealizedElement.remove()
				
				realizedElement = element.realize(parentElement)
			}
		} else {
			realizedElement = element.realize(parentElement)
		}

		realizedElement?.layoutFromRoot()
	}
}

private class FewListCell: UITableViewCell {
	private lazy var parentElement: RealizedElement = {[unowned self] in
		return RealizedElement(element: Element(), view: self.contentView, parent: nil)
	}()
	private var realizedElement: RealizedElement?
	
	func updateWithElement(element: Element) {
		if let oldRealizedElement = realizedElement {
			if element.canDiff(oldRealizedElement.element) {
				element.applyDiff(oldRealizedElement.element, realizedSelf: oldRealizedElement)
			} else {
				oldRealizedElement.remove()

				realizedElement = element.realize(parentElement)
			}
		} else {
			realizedElement = element.realize(parentElement)
		}

		realizedElement?.layoutFromRoot()
	}
}

private let cellKey = "ListCell"
private let headerKey = "ListHeader"
private let footerKey = "ListFooter"

private class TableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
	let tableView: UITableView

	var cachedHeights: [String: CGFloat] = [:]

	// Call `update` rather than setting these directly
	var elements: [[Element]]
	var headers: [Element?]
	var footers: [Element?]
	let headerView = FewTableHeaderFooter()
	let footerView = FewTableHeaderFooter()

	var selectionChanged: (NSIndexPath -> ())?
	
	init(tableView: UITableView, elements: [[Element]], headers: [Element?], footers: [Element?]) {
		self.tableView = tableView
		self.elements = elements
		self.headers = headers
		self.footers = footers
		super.init()
		headerView.didChangeHeight = {[weak tableView] view in
			if let tableView = tableView where tableView.tableHeaderView == view {
				// set header again to force table view to update contentSize & row offset
				tableView.tableHeaderView = view
				// begin/end updates because otherwise table view
				// randomly miscomputes its row offset after header height change
				UIView.performWithoutAnimation {
					tableView.beginUpdates()
					tableView.endUpdates()
				}
			}
		}
		footerView.didChangeHeight = {[weak tableView] view in
			// set footer again to force table view to update contentSize
			if let tableView = tableView where tableView.tableFooterView == view {
				tableView.tableFooterView = view
			}
		}
		tableView.registerClass(FewSectionHeaderFooter.self, forHeaderFooterViewReuseIdentifier: headerKey)
		tableView.registerClass(FewSectionHeaderFooter.self, forHeaderFooterViewReuseIdentifier: footerKey)
		tableView.registerClass(FewListCell.self, forCellReuseIdentifier: cellKey)
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	func update(elements: [[Element]], sectionHeaders: [Element?], sectionFooters: [Element?]) {
		self.elements = elements
		self.headers = sectionHeaders
		self.footers = sectionFooters

		updateCachedHeights()
		tableView.reloadData()
	}
	
	// MARK: UITableViewDelegate
	
	@objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let element = elements[indexPath.section][indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(cellKey, forIndexPath: indexPath) as! FewListCell
		cell.updateWithElement(element)
		return cell
	}
	
	@objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		let element = elements[indexPath.section][indexPath.row]
		return cachedHeights[memoryAddress(element)] ?? defaultRowHeight
	}
	
	@objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return elements.count
	}
	
	@objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return elements[section].count
	}
	
	@objc func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		selectionChanged?(indexPath)
	}
	
	@objc func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section < headers.count {
			if let header = headers[section] {
				return cachedHeights[memoryAddress(header)] ?? 0
			}
		}
		return 0
	}
	
	@objc func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section < headers.count {
			if let header = headers[section] {
				let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerKey) as! FewSectionHeaderFooter
				view.updateWithElement(header)
				return view
			}
		}
		return nil
	}
	
	@objc func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section < footers.count {
			if let footer = footers[section] {
				return cachedHeights[memoryAddress(footer)] ?? 0
			}
		}
		return 0
	}
	
	@objc func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if section < footers.count {
			if let footer = footers[section] {
				let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(footerKey) as! FewSectionHeaderFooter
				view.updateWithElement(footer)
				return view
			}
		}
		return nil
	}

	func updateCachedHeights() {
		var allElements = [Element?]()
		for section in elements {
			allElements += section.map { row in Optional(row) }
		}
		allElements += headers
		allElements += footers

		cachedHeights.removeAll(keepCapacity: true)
		for element in allElements {
			if let element = element {
				let node = element.assembleLayoutNode()
				let layout = node.layout(maxWidth: tableView.frame.size.width)
				cachedHeights[memoryAddress(element)] = layout.frame.size.height
			}
		}
	}
}

private class FewTableView: UITableView {
	var handler: TableViewHandler?
}

public class TableView: Element {
	private let elements: [[Element]]
	private let selectionChanged: (NSIndexPath -> ())?
	private let selectedRow: NSIndexPath?
	private let sectionHeaders: [Element?]
	private let sectionFooters: [Element?]
	private let header: Element?
	private let footer: Element?
	
	public init(_ elements: [[Element]], sectionHeaders: [Element?] = [], sectionFooters: [Element?] = [], header: Element? = nil, footer: Element? = nil, selectedRow: NSIndexPath? = nil, selectionChanged: (NSIndexPath -> ())? = nil) {
		self.elements = elements
		self.selectionChanged = selectionChanged
		self.selectedRow = selectedRow
		self.sectionHeaders = sectionHeaders
		self.sectionFooters = sectionFooters
		self.header = header
		self.footer = footer
	}
	
	// MARK: -
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)
		
		if let tableView = realizedSelf?.view as? FewTableView, handler = tableView.handler, oldSelf = old as? TableView {
			
			handler.update(elements, sectionHeaders: sectionHeaders, sectionFooters: sectionFooters)
			handler.selectionChanged = selectionChanged
			let tableSelected = tableView.indexPathForSelectedRow()
			if tableSelected != selectedRow {
				if let selectedRow = selectedRow {
					tableView.selectRowAtIndexPath(selectedRow, animated: false, scrollPosition: .None)
				} else if let tableSelected = tableSelected {
					tableView.deselectRowAtIndexPath(tableSelected, animated: false)
				}
			}
			if let header = header {
				handler.headerView.updateWithElement(header)
				if tableView.tableHeaderView != handler.headerView {
					tableView.tableHeaderView = handler.headerView
				}
			} else if tableView.tableHeaderView == handler.headerView {
				tableView.tableHeaderView = nil
			}
			if let footer = footer {
				handler.footerView.updateWithElement(footer)
				if tableView.tableFooterView != handler.footerView {
					tableView.tableFooterView = handler.footerView
				}
			} else if tableView.tableFooterView == handler.footerView {
				tableView.tableFooterView = nil
			}

		}

	}
	
	public override func createView() -> ViewType {
		let tableView = FewTableView()
		let handler = TableViewHandler(tableView: tableView, elements: elements, headers: sectionHeaders, footers: sectionFooters)
		tableView.handler = handler
		tableView.handler?.selectionChanged = selectionChanged
		tableView.alpha = alpha
		tableView.hidden = hidden
		if let header = header {
			handler.headerView.updateWithElement(header)
			let layout = header.assembleLayoutNode().layout(maxWidth: tableView.frame.width)
			layout.apply(handler.headerView)
			tableView.tableHeaderView = handler.headerView
		}
		if let footer = footer {
			handler.footerView.updateWithElement(footer)
			let layout = footer.assembleLayoutNode().layout(maxWidth: tableView.frame.width)
			layout.apply(handler.footerView)
			tableView.tableFooterView = handler.footerView
		}
		return tableView
	}

	public override func elementDidLayout(realizedSelf: RealizedElement?) {
		super.elementDidLayout(realizedSelf)

		if let scrollView = realizedSelf?.view as? FewTableView {
			let handler = scrollView.handler

			handler?.update(elements, sectionHeaders: sectionHeaders, sectionFooters: sectionFooters)
		}
	}
}