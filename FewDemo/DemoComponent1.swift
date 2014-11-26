//
//  DemoComponent1.swift
//  Few
//
//  Created by Josh Abernathy on 10/31/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct DemoState1 {
	let todos: [String] = []
	let like = false
}

class DemoComponent1<S>: Few.Component<DemoState1> {
	init() {
		let initialState = DemoState1(todos: (1...100).map { "Todo #\($0)" }, like: false)
		super.init(render: DemoComponent1.render, initialState: initialState)
	}

	class func render(component: Few.Component<DemoState1>, state: DemoState1) -> Element {
		let count = Label(text: "\(state.todos.count)")

		let button = Button(title: "Add") {
			component.replaceState(DemoState1(todos: state.todos + ["a nu todo"], like: state.like))
		}

		let likedness = (state.like ? "do" : "donut")
		let statusLabel = Label(text: "I \(likedness) like this.")

		let toggleButton = Button(title: "Toggle") {
			component.replaceState(DemoState1(todos: state.todos, like: !state.like))
		}

		let likesIt = Label(text: "He likes it he really likes it!")

		var children = [count, button, statusLabel, toggleButton]
		if !state.like {
			children += [likesIt]
		}

		// The [Element] cast is necessary otherwise Swift loses it shit at runtime.
		// "NSArray element failed to match the Swift Array Element type"
		let todos = state.todos.map { Label(text: $0) } as [Element]
		let list = List(todos)
		list.frame.size = CGSize(width: 100, height: 100)
		children += [list]

		return Container(verticalStack(360, 4, leftAlign(16, children)))
	}
}
