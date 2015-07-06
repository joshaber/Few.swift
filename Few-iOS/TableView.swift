//
//  TableView.swift
//  Few
//
//  Created by Coen Wessels on 13-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private let defaultRowHeight: CGFloat = 42

private class FewListHeaderFooter: UITableViewHeaderFooterView {
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

	var selectionChanged: (NSIndexPath -> ())?
	
	init(tableView: UITableView, elements: [[Element]], headers: [Element?], footers: [Element?]) {
		self.tableView = tableView
		self.elements = elements
		self.headers = headers
		self.footers = footers
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
				let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerKey) as! FewListHeaderFooter
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
				let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(footerKey) as! FewListHeaderFooter
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
	private let headers: [Element?]
	private let footers: [Element?]
	
	public init(_ elements: [[Element]], headers: [Element?] = [], footers: [Element?] = [], selectedRow: NSIndexPath? = nil, selectionChanged: (NSIndexPath -> ())? = nil) {
		self.elements = elements
		self.selectionChanged = selectionChanged
		self.selectedRow = selectedRow
		self.headers = headers
		self.footers = footers
	}
	
	// MARK: -
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)
		
		if let tableView = realizedSelf?.view as? FewTableView {
			let handler = tableView.handler
			
			handler?.update(elements, headers: headers, footers: footers)
			handler?.selectionChanged = selectionChanged
			let tableSelected = tableView.indexPathForSelectedRow()
			if tableSelected != selectedRow {
				if let selectedRow = selectedRow {
					tableView.selectRowAtIndexPath(selectedRow, animated: false, scrollPosition: .None)
				} else if let tableSelected = tableSelected {
					tableView.deselectRowAtIndexPath(tableSelected, animated: false)
				}
			}
		}
	}
	
	public override func createView() -> ViewType {
		let tableView = FewTableView(frame: CGRectZero)
		tableView.handler = TableViewHandler(tableView: tableView, elements: elements, headers: headers, footers: footers)
		tableView.handler?.selectionChanged = selectionChanged
		tableView.alpha = alpha
		tableView.hidden = hidden
		
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