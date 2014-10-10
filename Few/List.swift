//
//  List.swift
//  Few
//
//  Created by Josh Abernathy on 10/5/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private let defaultRowHeight: CGFloat = 42

func indexOf<T: AnyObject>(array: [T], element: T) -> Int? {
	for (i, e) in enumerate(array) {
		if e === element { return i }
	}

	return nil
}

func objectsToIndexes<T: AnyObject>(whole: [T], some: [T]) -> NSIndexSet {
	return some.map { e in
		return indexOf(whole, e)
	}.reduce(NSMutableIndexSet(indexesInRange: NSMakeRange(0, 0))) { (set, index: Int?) in
		set.addIndex <^> index
		return set
	}
}

private class TableViewHandler: NSObject, NSTableViewDelegate, NSTableViewDataSource {
	let tableView: NSTableView
	unowned var list: List

	var items: [Element] {
		didSet {
			let (add, remove) = diffElementLists(oldValue, items, false)
			if add.count == 0 && remove.count == 0 { return }

			let addIndexes = objectsToIndexes(items, add)
			let removeIndexes = objectsToIndexes(oldValue, remove)

			tableView.beginUpdates()
			tableView.insertRowsAtIndexes(addIndexes, withAnimation: .EffectNone)
			tableView.removeRowsAtIndexes(removeIndexes, withAnimation: .EffectNone)
			tableView.endUpdates()
		}
	}

	init(tableView: NSTableView, items: [Element], list: List) {
		self.tableView = tableView
		self.items = items
		self.list = list
		super.init()

		tableView.setDelegate(self)
		tableView.setDataSource(self)
	}

	deinit {
		tableView.setDelegate(nil)
		tableView.setDataSource(nil)
	}

	// MARK: NSTableViewDelegate

	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let element = items[row]
		// LOLOLOL
		let component: Component<Any> = list.getComponent()!
		element.realize(component, parentView: tableView)
		return element.getContentView()
	}

	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		let height = NSHeight(items[row].frame)
		return height > CGFloat(0) ? height : defaultRowHeight
	}

	// MARK: NSTableViewDataSource

	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return items.count
	}
}

public class List: Element {
	private var scrollView: NSScrollView?
	private var tableView: NSTableView?
	private var handler: TableViewHandler?

	private let items: [Element]

	public init(_ items: [Element]) {
		self.items = items
	}

	// MARK: -

	public override func applyDiff(other: Element) {
		let otherList = other as List
		handler = otherList.handler
		scrollView = otherList.scrollView
		tableView = otherList.tableView

		super.applyDiff(other)

		handler?.list = self
		handler?.items = items
	}

	public override func realize<S>(component: Component<S>, parentView: ViewType) {
		let scrollView = NSScrollView(frame: frame)
		self.scrollView = scrollView

		let tableView = NSTableView(frame: scrollView.bounds)
		self.tableView = tableView

		let column = NSTableColumn(identifier: "ListColumn")
		column.width = tableView.bounds.size.width
		tableView.addTableColumn(column)

		tableView.headerView = nil

		scrollView.documentView = tableView

		let handler = TableViewHandler(tableView: tableView, items: items, list: self)
		self.handler = handler

		super.realize(component, parentView: parentView)
	}

	public override func getContentView() -> ViewType? {
		return scrollView
	}
}
