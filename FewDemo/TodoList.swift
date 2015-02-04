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

	class func render(c: Few.Component<Array<String>>, todos: [String]) -> Element {
		return Empty()
	}
}
