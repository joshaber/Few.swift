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

	init(logoutFn: () -> ()) {
		let initialState = DemoState1(todos: (1...100).map { "Todo #\($0)" }, like: false, watcherCount: nil, selectedIndex: nil)
		super.init(render: DemoComponent1.render(logoutFn), initialState: initialState)
	}

	required init(copy: Element, frame: CGRect, hidden: Bool, key: String?) {
		super.init(copy: copy, frame: frame, hidden: hidden, key: key);
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
				self.updateState { DemoState1(todos: $0.todos, like: $0.like, watcherCount: watchers, selectedIndex: $0.selectedIndex) }
			}
		}

		eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { [unowned self] event in
			self.handleEvent(event)
		}
	}

	func handleEvent(event: NSEvent) -> NSEvent? {
		let characters = event.charactersIgnoringModifiers! as NSString
		let character = Int(characters.characterAtIndex(0))
		let listView = getView(self.list!)!
		let firstResponder = event.window?.firstResponder as? ViewType
		if let firstResponderView = firstResponder {
			if character == NSDeleteCharacter && (firstResponder == listView || firstResponderView.isDescendantOf(listView)) {
				let state = getState()
				if let index = state.selectedIndex {
					var todos = state.todos
					todos.removeAtIndex(index)

					let selectedIndex = (index <= todos.count && index > 0 ? index - 1 : 0)
					updateState { DemoState1(todos: todos, like: $0.like, watcherCount: $0.watcherCount, selectedIndex: selectedIndex) }

					return nil
				}
			}
		}

		return event
	}

	override func componentWillDerealize() {
		NSEvent.removeMonitor <^> eventMonitor
	}

	class func render(logoutFn: () -> ())(component: Few.Component<DemoState1>, state: DemoState1) -> Element {
		let count = Label(text: "\(state.todos.count)")

		let button = Button(title: "Add") {
			component.updateState { DemoState1(todos: $0.todos + ["a nu todo"], like: $0.like, watcherCount: $0.watcherCount, selectedIndex: $0.selectedIndex) }
		}

		let likedness = (state.like ? "do" : "donut")
		let statusLabel = Label(text: "I \(likedness) like this.")

		let toggleButton = Button(title: "Toggle") {
			component.updateState { DemoState1(todos: $0.todos, like: !$0.like, watcherCount: $0.watcherCount, selectedIndex: $0.selectedIndex) }
		}.width(54)

		var likesIt = maybe(state.watcherCount, Label(text: "Checking…")) {
			Label(text: "\($0) people like us!!!")
		}
		if !state.like {
			likesIt = likesIt.hide()
		}

		let todos = state.todos.map { str in Label(text: str).key(str) }
		let list = List(todos, selectedRow: state.selectedIndex) { index in
			component.updateState { DemoState1(todos: $0.todos, like: $0.like, watcherCount: $0.watcherCount, selectedIndex: (index > -1 ? index : nil)) }
		}.width(100).height(100)

		let c = component as DemoComponent1
		c.list = list

		let logoutButton = Button(title: "Logout", action: logoutFn).width(100).height(23)
		
		let children = [count, button, statusLabel, toggleButton, likesIt, list, logoutButton]
		return Container(children |> leftAlign(16) |> verticalStack(component.frame.size.height, 4))
	}
}
