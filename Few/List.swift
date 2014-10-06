//
//  List.swift
//  Few
//
//  Created by Josh Abernathy on 10/5/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private class TableViewHandler: NSObject, NSTableViewDelegate, NSTableViewDataSource {
	var items: [Element]

	init(items: [Element]) {
		self.items = items
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

	init(_ items: [Element]) {
		self.items = items
	}

	deinit {
		tableView?.setDelegate(nil)
		tableView?.setDataSource(nil)
	}

	// MARK: -

	public override func applyDiff(other: Element) {
		let otherList = other as List
		scrollView = otherList.scrollView
		tableView = otherList.tableView
		handler = otherList.handler

		super.applyDiff(other)
	}

	public override func realize<S>(component: Component<S>, parentView: ViewType) {
		let scrollView = NSScrollView(frame: frame)
		self.scrollView = scrollView

		let tableView = NSTableView(frame: scrollView.bounds)
		self.tableView = tableView

		let column = NSTableColumn(identifier: "ListColumn")
		column.width = tableView.bounds.size.width
		tableView.addTableColumn(column)

		scrollView.documentView = tableView

		let handler = TableViewHandler(items: items)
		self.handler = handler

		tableView.setDataSource(handler)
		tableView.setDelegate(handler)
	}

	public override func getContentView() -> ViewType? {
		return scrollView
	}
}
