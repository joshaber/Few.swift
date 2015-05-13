//
//  TableView.swift
//  Few
//
//  Created by Josh Abernathy on 2/21/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private var ElementKey = "ElementKey"

private let defaultRowHeight: CGFloat = 42

private class FewListCell: NSTableCellView {
	private var realizedElement: RealizedElement?
	private var parent: RealizedElement!

	func updateWithElement(element: Element) {
		if parent == nil {
			parent = RealizedElement(element: Element(), view: self, parent: nil)
		}

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
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private class TableViewHandler: NSObject, NSTableViewDelegate, NSTableViewDataSource {
	let tableView: NSTableView

	var supressChangeNotification = false

	var elements: [Element] {
		didSet {
			let selectedRows = tableView.selectedRowIndexes
			tableView.reloadData()
			supressChangeNotification = true
			tableView.selectRowIndexes(selectedRows, byExtendingSelection: false)
			supressChangeNotification = false
		}
	}

	var selectionChanged: (Int -> ())?

	init(tableView: NSTableView, elements: [Element]) {
		self.tableView = tableView
		self.elements = elements
		super.init()

		tableView.setDelegate(self)
		tableView.setDataSource(self)
	}

	deinit {
		tableView.setDelegate(nil)
		tableView.setDataSource(nil)
	}

	// MARK: NSTableViewDelegate

	@objc func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let element = elements[row]

		let key = "ListCell"
		var listCell = tableView.makeViewWithIdentifier(key, owner: nil) as! FewListCell?
		if listCell == nil {
			let newListCell = FewListCell(frame: CGRectZero)
			newListCell.identifier = key

			listCell = newListCell
		}

		listCell?.updateWithElement(element)

		return listCell
	}

	@objc func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		let height = NSHeight(elements[row].frame)
		return height > CGFloat(0) ? height : defaultRowHeight
	}

	@objc func tableViewSelectionIsChanging(notification: NSNotification) {
		if supressChangeNotification { return }

		selectionChanged?(tableView.selectedRow)
	}

	@objc func tableViewSelectionDidChange(notification: NSNotification) {
		if supressChangeNotification { return }

		selectionChanged?(tableView.selectedRow)
	}

	// MARK: NSTableViewDataSource

	@objc func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return elements.count
	}
}

private class FewScrollView: NSScrollView {
	var handler: TableViewHandler?
}

public class TableView: Element {
	private let elements: [Element]
	private let selectionChanged: (Int -> ())?
	private let selectedRow: Int?

	public init(_ elements: [Element], selectedRow: Int? = nil, selectionChanged: (Int -> ())? = nil) {
		self.elements = elements
		self.selectionChanged = selectionChanged
		self.selectedRow = selectedRow
	}

	// MARK: -

	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		if let scrollView = realizedSelf?.view as? FewScrollView {
			let handler = scrollView.handler

			layoutElements()

			handler?.elements = elements

			let tableView = scrollView.handler?.tableView
			if tableView?.selectedRow != selectedRow {
				if let selectedRow = selectedRow {
					if selectedRow > -1 {
						tableView?.selectRowIndexes(NSIndexSet(index: selectedRow), byExtendingSelection: false)
					} else {
						tableView?.deselectAll(nil)
					}
				}
			}

			handler?.selectionChanged = selectionChanged
		}
	}

	public override func createView() -> ViewType {
		let scrollView = FewScrollView(frame: frame)
		scrollView.hasVerticalScroller = true
		scrollView.borderType = .BezelBorder
		scrollView.alphaValue = alpha
		scrollView.hidden = hidden

		let tableView = NSTableView(frame: scrollView.bounds)

		let column = NSTableColumn(identifier: "ListColumn")
		column.width = tableView.bounds.size.width
		tableView.addTableColumn(column)

		tableView.headerView = nil

		scrollView.documentView = tableView

		layoutElements()

		scrollView.handler = TableViewHandler(tableView: tableView, elements: elements)
		scrollView.handler?.selectionChanged = selectionChanged
		
		return scrollView
	}

	private final func layoutElements() {
		for element in elements {
			let node = element.assembleLayoutNode()
			let layout = node.layout(maxWidth: frame.size.width)
			element.applyLayout(layout)
		}
	}
}
