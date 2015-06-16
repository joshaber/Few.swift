//
//  TableView.swift
//  Few
//
//  Created by Coen Wessels on 13-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private let defaultRowHeight: CGFloat = 42

private class FewContainerView: UIView {
	private var realizedElement: RealizedElement?
	
	func updateWithElement(element: Element, parent: RealizedElement) {
		if let realizedElement = realizedElement {
			if element.canDiff(realizedElement.element) {
				element.applyDiff(realizedElement.element, realizedSelf: realizedElement)
			} else {
				realizedElement.remove()
				
				self.realizedElement = element.realize(parent)
			}
		} else {
			realizedElement = element.realize(parent)
		}
		
		realizedElement?.layoutFromRoot()
	}
}

/// this is used as a container for section header/footers
private class FewListHeaderFooter: UITableViewHeaderFooterView {
	private var realizedElement: RealizedElement?
	
	func updateWithElement(element: Element, parent: RealizedElement) {
		if let realizedElement = realizedElement {
			if element.canDiff(realizedElement.element) {
				element.applyDiff(realizedElement.element, realizedSelf: realizedElement)
			} else {
				realizedElement.remove()
				
				self.realizedElement = element.realize(parent)
			}
		} else {
			realizedElement = element.realize(parent)
		}

		realizedElement?.layoutFromRoot()
	}
}

private class FewListCell: UITableViewCell {
	private var realizedElement: RealizedElement?
	
	func updateWithElement(element: Element, parent: RealizedElement) {
		if let realizedElement = realizedElement {
			if element.canDiff(realizedElement.element) {
				element.applyDiff(realizedElement.element, realizedSelf: realizedElement)
			} else {
				realizedElement.remove()

				self.realizedElement = element.realize(parent)
			}
		} else {
			realizedElement = element.realize(parent)
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
	let headerParent: RealizedElement
	let footerParent: RealizedElement
	
	var headerView: FewContainerView {
		return headerParent.view! as! FewContainerView
	}
	
	var footerView: FewContainerView {
		return footerParent.view! as! FewContainerView
	}

	var parents = [String: RealizedElement]()

	var selectionChanged: (NSIndexPath -> ())?
	
	init(tableView: UITableView, elements: [[Element]], headers: [Element?], footers: [Element?]) {
		self.tableView = tableView
		self.elements = elements
		self.headers = headers
		self.footers = footers
		headerParent = RealizedElement(element: Element(), view: FewContainerView(), parent: nil)
		footerParent = RealizedElement(element: Element(), view: FewContainerView(), parent: nil)
		super.init()
		tableView.registerClass(FewListHeaderFooter.self, forHeaderFooterViewReuseIdentifier: headerKey)
		tableView.registerClass(FewListHeaderFooter.self, forHeaderFooterViewReuseIdentifier: footerKey)
		tableView.registerClass(FewListCell.self, forCellReuseIdentifier: cellKey)
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	func update(elements: [[Element]], headers: [Element?], footers: [Element?]) {
		self.elements = elements
		self.headers = headers
		self.footers = footers

		updateCachedHeights()
		tableView.reloadData()
	}
	
	func parentForCell(cell: FewListCell) -> RealizedElement {
		let key = memoryAddress(cell)
		let result: RealizedElement
		if let existing = parents[key] {
			result = existing
		} else {
			result = RealizedElement(element: Element(), view: cell.contentView, parent: nil)
			parents[key] = result
		}
		return result
	}
	
	func parentForHeaderFooter(view: FewListHeaderFooter) -> RealizedElement {
		let key = memoryAddress(view)
		let result: RealizedElement
		if let existing = parents[key] {
			result = existing
		} else {
			result = RealizedElement(element: Element(), view: view.contentView, parent: nil)
			parents[key] = result
		}
		return result
	}
	
	// MARK: UITableViewDelegate
	
	@objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let element = elements[indexPath.section][indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(cellKey, forIndexPath: indexPath) as! FewListCell
		cell.updateWithElement(element, parent: parentForCell(cell))
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
				let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerKey) as! FewListHeaderFooter
				view.updateWithElement(header, parent: parentForHeaderFooter(view))
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
				let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(footerKey) as! FewListHeaderFooter
				view.updateWithElement(footer, parent: parentForHeaderFooter(view))
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
	private let headers: [Element?]
	private let footers: [Element?]
	private let header: Element?
	private let footer: Element?
	
	public init(_ elements: [[Element]], headers: [Element?] = [], footers: [Element?] = [], header: Element? = nil, footer: Element? = nil, selectedRow: NSIndexPath? = nil, selectionChanged: (NSIndexPath -> ())? = nil) {
		self.elements = elements
		self.selectionChanged = selectionChanged
		self.selectedRow = selectedRow
		self.headers = headers
		self.footers = footers
		self.header = header
		self.footer = footer
	}
	
	// MARK: -
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)
		
		if let tableView = realizedSelf?.view as? FewTableView, handler = tableView.handler, oldSelf = old as? TableView {
			
			handler.update(elements, headers: headers, footers: footers)
			handler.selectionChanged = selectionChanged
			let tableSelected = tableView.indexPathForSelectedRow()
			if tableSelected?.row != selectedRow {
				if let selectedRow = selectedRow {
					tableView.selectRowAtIndexPath(selectedRow, animated: false, scrollPosition: .None)
				} else if let tableSelected = tableSelected {
					tableView.deselectRowAtIndexPath(tableSelected, animated: false)
				}
			}
			if let header = header {
				handler.headerView.updateWithElement(header, parent: handler.headerParent)
				let layout = header.assembleLayoutNode().layout(maxWidth: tableView.frame.width)
				let oldHeight = handler.headerView.frame.height
				layout.apply(handler.headerView)
				if oldHeight != handler.headerView.frame.height {
					tableView.tableHeaderView = handler.headerView
					// required or else table view may put rows in the wrong spot
					UIView.performWithoutAnimation {
						tableView.beginUpdates()
						tableView.endUpdates()
					}
				}
			} else if tableView.tableHeaderView == handler.headerView {
				tableView.tableHeaderView = nil
			}
			if let footer = footer {
				handler.footerView.updateWithElement(footer, parent: handler.footerParent)
				let layout = footer.assembleLayoutNode().layout(maxWidth: tableView.frame.width)
				let oldHeight = handler.footerView.frame.height
				layout.apply(handler.footerView)
				if oldHeight != handler.footerView.frame.height {
					tableView.tableFooterView = handler.footerView
				}
			} else if tableView.tableFooterView == handler.footerView {
				tableView.tableFooterView = nil
			}

		}

	}
	
	public override func createView() -> ViewType {
		let tableView = FewTableView(frame: UIScreen.mainScreen().bounds)
		let handler = TableViewHandler(tableView: tableView, elements: elements, headers: headers, footers: footers)
		tableView.handler = handler
		tableView.handler?.selectionChanged = selectionChanged
		tableView.alpha = alpha
		tableView.hidden = hidden
		if let header = header {
			handler.headerView.updateWithElement(header, parent: handler.headerParent)
			let layout = header.assembleLayoutNode().layout(maxWidth: tableView.frame.width)
			layout.apply(handler.headerView)
			tableView.tableHeaderView = handler.headerView
		}
		if let footer = footer {
			handler.footerView.updateWithElement(footer, parent: handler.footerParent)
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

			handler?.update(elements, headers: headers, footers: footers)
		}
	}
}