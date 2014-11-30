//
//  DemoComponent1.swift
//  Few
//
//  Created by Josh Abernathy on 10/31/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

func GET(URL: NSURL, fn: (NSDictionary!, NSURLResponse!, NSError!) -> ()) {
	NSURLSession.sharedSession().dataTaskWithURL(URL) { (data, response, error) in
		if data == nil {
			fn(nil, response, error)
			return
		}

		var JSONError: NSError?
		let result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &JSONError) as? NSDictionary
		fn(result, response, JSONError)
	}.resume()
}

struct DemoState1 {
	let todos: [String] = []
	let like = false
	let watcherCount: Int?
}

class DemoComponent1<S>: Few.Component<DemoState1> {
	init() {
		let initialState = DemoState1(todos: (1...100).map { "Todo #\($0)" }, like: false, watcherCount: nil)
		super.init(render: DemoComponent1.render, initialState: initialState)
	}

	override func componentDidRealize() {
		let URL = NSURL(string: "https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa")
		GET(URL!) { (JSON, response, error) in
			if JSON == nil {
				println("Error: \(error)")
				println("Response: \(response)")
				return
			}

			let watchers = JSON["watchers_count"] as? Int
			dispatch_async(dispatch_get_main_queue()) {
				let state = self.getState()
				self.replaceState(DemoState1(todos: state.todos, like: state.like, watcherCount: watchers))
			}
		}
	}

	class func render(component: Few.Component<DemoState1>, state: DemoState1) -> Element {
		let count = Label(text: "\(state.todos.count)")

		let button = Button(title: "Add") {
			component.replaceState(DemoState1(todos: state.todos + ["a nu todo"], like: state.like, watcherCount: state.watcherCount))
		}

		let likedness = (state.like ? "do" : "donut")
		let statusLabel = Label(text: "I \(likedness) like this.")

		let toggleButton = Button(title: "Toggle") {
			component.replaceState(DemoState1(todos: state.todos, like: !state.like, watcherCount: state.watcherCount))
		}

		let likesIt = maybe(state.watcherCount, Label(text: "Checking…")) {
			Label(text: "\($0) people like us!!!")
		}

		var children = [count, button, statusLabel, toggleButton]
		if !state.like {
			children += [likesIt]
		}

		let todos = state.todos.map { Label(text: $0) }
		let list = List(todos)
		list.frame.size = CGSize(width: 100, height: 100)
		children += [list]

		return Container(verticalStack(360, 4, leftAlign(16, children)))
	}
}
