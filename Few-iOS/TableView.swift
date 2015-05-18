//
//  TableView.swift
//  Few
//
//  Created by Coen Wessels on 13-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private var ElementKey = "ElementKey"

private let defaultRowHeight: CGFloat = 42

private class FewListHeaderFooter: UITableViewHeaderFooterView {
	private var realizedElement: RealizedElement?
	
	func updateWithElement(element: Element) {
		if let realizedElement = realizedElement {
			if element.canDiff(realizedElement.element) {
				element.applyDiff(realizedElement.element, realizedSelf: realizedElement)
			} else {
				realizedElement.remove()
				
				let parent = RealizedElement(element: Element(), view: contentView, parent: nil)
				self.realizedElement = element.realize(parent)
			}
		} else {
			let parent = RealizedElement(element: Element(), view: contentView, parent: nil)
			realizedElement = element.realize(parent)
		}
	}
}

private class FewListCell: UITableViewCell {
	private var realizedElement: RealizedElement?
	
	func updateWithElement(element: Element) {
		if let realizedElement = realizedElement {
			if element.canDiff(realizedElement.element) {
				element.applyDiff(realizedElement.element, realizedSelf: realizedElement)
			} else {
				realizedElement.remove()

				let parent = RealizedElement(element: Element(), view: contentView, parent: nil)
				self.realizedElement = element.realize(parent)
			}
		} else {
			let parent = RealizedElement(element: Element(), view: contentView, parent: nil)
			realizedElement = element.realize(parent)
		}
	}
}

private let cellKey = "ListCell"
private let headerKey = "ListHeader"
private let footerKey = "ListFooter"

private class TableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
	let tableView: UITableView
	
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
		let height = elements[indexPath.section][indexPath.row].frame.height
		return height > CGFloat(0) ? height : defaultRowHeight
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
				return header.frame.height
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
				return footer.frame.height
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
			
			layoutElements()
			handler?.update(elements, headers: headers, footers: footers)
			handler?.selectionChanged = selectionChanged
			let tableSelected = tableView.indexPathForSelectedRow()
			if tableSelected?.row != selectedRow {
				if let selectedRow = selectedRow {
					tableView.selectRowAtIndexPath(selectedRow, animated: false, scrollPosition: .None)
				} else if let tableSelected = tableSelected {
					tableView.deselectRowAtIndexPath(tableSelected, animated: false)
				}
			}
		}
	}
	
	public override func createView() -> ViewType {
		let tableView = FewTableView(frame: frame)
		layoutElements()
		tableView.handler = TableViewHandler(tableView: tableView, elements: elements, headers: headers, footers: footers)
		tableView.handler?.selectionChanged = selectionChanged
		tableView.alpha = alpha
		tableView.hidden = hidden
		
		return tableView
	}
	
	private final func layoutElements() {
		var allElements = [Element?]()
		for section in elements {
			allElements += section.map { row in Optional(row) }
		}
		allElements += headers
		allElements += footers
		
		for element in allElements {
			if let element = element {
				let node = element.assembleLayoutNode()
				let layout = node.layout(maxWidth: frame.width)
				element.applyLayout(layout)
			}
		}
	}
}