//
//  TableView.swift
//  Few
//
//  Created by Josh Abernathy on 2/21/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private let defaultRowHeight: CGFloat = 42

private class FewListCell: NSTableCellView {
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

	var parents: [String: RealizedElement] = [:]

	var elements: [Element] {
		didSet {
			updateCachedHeights()

			let selectedRows = tableView.selectedRowIndexes
			tableView.reloadData()
			supressChangeNotification = true
			tableView.selectRowIndexes(selectedRows, byExtendingSelection: false)
			supressChangeNotification = false
		}
	}

	var cachedHeights: [String: CGFloat] = [:]

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

			let parent = RealizedElement(element: Element(), view: newListCell, parent: nil)
			parents[parentKeyForCell(newListCell)] = parent

			listCell = newListCell
		}

		let parent = parents[parentKeyForCell(listCell!)]!
		listCell?.updateWithElement(element, parent: parent)

		return listCell
	}

	func parentKeyForCell(cell: FewListCell) -> String {
		return memoryAddress(cell)
	}

	@objc func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		let element = elements[row]
		return cachedHeights[memoryAddress(element)] ?? defaultRowHeight
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

	func updateCachedHeights() {
		cachedHeights.removeAll(keepCapacity: true)
		for element in elements {
			let node = element.assembleLayoutNode()
			let layout = node.layout(maxWidth: tableView.frame.size.width)
			cachedHeights[memoryAddress(element)] = layout.frame.size.height
		}
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
		let scrollView = FewScrollView(frame: CGRectZero)
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

		scrollView.handler = TableViewHandler(tableView: tableView, elements: elements)
		scrollView.handler?.selectionChanged = selectionChanged
		
		return scrollView
	}

	public override func elementDidLayout(realizedSelf: RealizedElement?) {
		super.elementDidLayout(realizedSelf)

		if let scrollView = realizedSelf?.view as? FewScrollView {
			let handler = scrollView.handler

			handler?.elements = elements
		}
	}
}
