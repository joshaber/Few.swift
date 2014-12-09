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
	let selectedIndex: Int?
}

class DemoComponent1<S>: Few.Component<DemoState1> {
	var eventMonitor: AnyObject?

	var list: List?

	init() {
		let initialState = DemoState1(todos: (1...100).map { "Todo #\($0)" }, like: false, watcherCount: nil, selectedIndex: nil)
		super.init(render: DemoComponent1.render, initialState: initialState)
	}

	override func componentDidRealize() {
		let URL = NSURL(string: "https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa")
		GET(URL!) { JSON, response, error in
			if JSON == nil {
				println("Error: \(error)")
				println("Response: \(response)")
				return
			}

			let watchers = JSON["watchers_count"] as? Int
			dispatch_async(dispatch_get_main_queue()) {
				let state = self.getState()
				self.updateState { DemoState1(todos: $0.todos, like: $0.like, watcherCount: watchers, selectedIndex: $0.selectedIndex) }
			}
		}

		eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { event in
			let characters = event.charactersIgnoringModifiers! as NSString
			let character = Int(characters.characterAtIndex(0))
			if character == NSDeleteCharacter {
				let state = self.getState()
				if let index = state.selectedIndex {
					println("Delete \(state.todos[index])")

					var todos = state.todos
					todos.removeAtIndex(index)

					let selectedIndex = (todos.count > 0 ? 0 : -1)
					self.updateState { DemoState1(todos: todos, like: $0.like, watcherCount: $0.watcherCount, selectedIndex: selectedIndex) }

					return nil
				}
			}
			println(event.window?.firstResponder)
			return event
		}
	}

	override func componentWillDerealize() {
		NSEvent.removeMonitor <^> eventMonitor
	}

	class func render(component: Few.Component<DemoState1>, state: DemoState1) -> Element {
		let count = Label(text: "\(state.todos.count)")

		let button = Button(title: "Add") {
			component.updateState { DemoState1(todos: $0.todos + ["a nu todo"], like: $0.like, watcherCount: $0.watcherCount, selectedIndex: $0.selectedIndex) }
		}

		let likedness = (state.like ? "do" : "donut")
		let statusLabel = Label(text: "I \(likedness) like this.")

		let toggleButton = Button(title: "Toggle") {
			component.updateState { DemoState1(todos: $0.todos, like: !$0.like, watcherCount: $0.watcherCount, selectedIndex: $0.selectedIndex) }
		}
		toggleButton.frame.size.width = 54

		let likesIt = maybe(state.watcherCount, Label(text: "Checking…")) {
			Label(text: "\($0) people like us!!!")
		}
		likesIt.hidden = !state.like

		let todos: [Label] = state.todos.map { str in
			let label = Label(text: str)
			label.key = str
			return label
		}
		let list = List(todos, selectedRow: state.selectedIndex) { index in
			component.updateState { DemoState1(todos: $0.todos, like: $0.like, watcherCount: $0.watcherCount, selectedIndex: (index > -1 ? index : nil)) }
		}
		list.frame.size = CGSize(width: 100, height: 100)

		let c = component as DemoComponent1
		c.list = list

		let children = [count, button, statusLabel, toggleButton, likesIt, list]
		return Container(children |> leftAlign(16) |> verticalStack(component.frame.size.height, 4))
	}
}
