//
//  DemoComponent1.swift
//  Few
//
//  Created by Josh Abernathy on 10/31/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct AppState {
	let todos: [String] = []
	let like = false
}

class DemoComponent1<S>: Few.Component<AppState> {
	init() {
		let initialState = AppState(todos: (1...100).map { "Todo #\($0)" }, like: false)
		super.init(render: DemoComponent1.renderApp, initialState: initialState)
	}

	class func renderApp(component: Few.Component<AppState>, state: AppState) -> Element {
		let count = Label(text: "\(state.todos.count)")

		let button = Button(title: "Add") {
			component.updateState { state in
				AppState(todos: state.todos + ["a nu todo"], like: state.like)
			}
			return ()
		}

		let likedness = (state.like ? "do" : "donut")
		let statusLabel = Label(text: "I \(likedness) like this.")

		let toggleButton = Button(title: "Toggle") {
			component.updateState { state in
				AppState(todos: state.todos, like: !state.like)
			}
			return ()
		}

		let graphic = fillRect(NSColor.greenColor())
		graphic.sizingBehavior = .Fixed(CGSize(width: 100, height: 100))

		var children = [count, button, statusLabel, toggleButton]
		if !state.like {
			children += [graphic]
		}

		// The [Element] cast is necessary otherwise Swift loses it shit at runtime.
		// "NSArray element failed to match the Swift Array Element type"
		let todos = state.todos.map { Label(text: $0) } as [Element]
		let list = List(todos)
		list.sizingBehavior = .Fixed(CGSize(width: 100, height: 100))
		children += [list]

		let layout = offset(CGPoint(x: 20, y: 0)) >-- verticalStack(12)
		return Container(children: children, layout: layout)
	}
}
