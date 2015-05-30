//
//  TableView.swift
//  Few
//
//  Created by Coen Wessels on 13-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private var ElementKey = "ElementKey"

private func memoryAddress(object: AnyObject) -> String {
	let ptr = Unmanaged<AnyObject>.passUnretained(object).toOpaque()
	return "\(ptr)"
}

private let defaultRowHeight: CGFloat = 42

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

private class TableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
	let tableView: UITableView
	
	var elements: [Element] {
		didSet {
			updateCachedHeights()

			tableView.reloadData()
		}
	}

	var cachedHeights: [String: CGFloat] = [:]
	
	var selectionChanged: (Int -> ())?
	
	init(tableView: UITableView, elements: [Element]) {
		self.tableView = tableView
		self.elements = elements
		super.init()
		tableView.registerClass(FewListCell.self, forCellReuseIdentifier: cellKey)
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	// MARK: UITableViewDelegate
	
	@objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let element = elements[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(cellKey, forIndexPath: indexPath) as! FewListCell
		cell.updateWithElement(element)
		return cell
	}
	
	@objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		let element = elements[indexPath.row]
		return cachedHeights[memoryAddress(element)] ?? defaultRowHeight
	}
	
	@objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	@objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return elements.count
	}
	
	@objc func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		selectionChanged?(indexPath.row)
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

private class FewTableView: UITableView {
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
		
		if let tableView = realizedSelf?.view as? FewTableView {
			let handler = tableView.handler

			handler?.elements = elements
			handler?.selectionChanged = selectionChanged
			let tableSelected = tableView.indexPathForSelectedRow()
			if tableSelected?.row != selectedRow {
				if let selectedRow = selectedRow {
					let indexPath = NSIndexPath(forRow: selectedRow, inSection: 0)
					tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
				} else if let tableSelected = tableSelected {
					tableView.deselectRowAtIndexPath(tableSelected, animated: false)
				}
			}
		}
	}
	
	public override func createView() -> ViewType {
		let tableView = FewTableView(frame: CGRectZero)
		tableView.handler = TableViewHandler(tableView: tableView, elements: elements)
		tableView.handler?.selectionChanged = selectionChanged
		tableView.alpha = alpha
		tableView.hidden = hidden
		
		return tableView
	}

	public override func elementDidLayout(realizedSelf: RealizedElement?) {
		super.elementDidLayout(realizedSelf)

		if let scrollView = realizedSelf?.view as? FewTableView {
			let handler = scrollView.handler

			handler?.elements = elements
		}
	}
}