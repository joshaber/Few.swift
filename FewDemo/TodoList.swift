//
//  TodoList.swift
//  Few
//
//  Created by Josh Abernathy on 12/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

typealias TodoList = TodoList_<[String]>
class TodoList_<Lol>: Few.Component<[String]> {
	let selectedRow: Int?
	let selectionChanged: Int? -> ()

	init(_ todos: [String], selectedRow: Int?, selectionChanged: Int? -> ()) {
		self.selectedRow = selectedRow
		self.selectionChanged = selectionChanged
		super.init(render: TodoList.render, initialState: todos)
	}

	required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let list = copy as TodoList_
		selectedRow = list.selectedRow
		selectionChanged = list.selectionChanged
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	class func render(c: Few.Component<Array<String>>, todos: [String]) -> Element {
		let component = c as TodoList
		let labels = todos.map { Label(text: $0).key($0) }
		let selectionChanged: Int -> () = { index in
			component.selectionChanged(index > -1 ? index : nil)
		}
		return List(labels, selectedRow: component.selectedRow, selectionChanged: selectionChanged)
	}
}
