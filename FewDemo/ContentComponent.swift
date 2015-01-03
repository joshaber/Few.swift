//
//  ContentComponent.swift
//  Few
//
//  Created by Josh Abernathy on 10/31/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct ContentState {
	let todos: [String] = []
	let like = false
	let watcherCount: Int?
	let selectedIndex: Int?
}

// Ideally this would be embedded in ContentComponent, but Swift can't do that yet.
private struct Keys {
	static let List = uniqueKey()
}

typealias ContentComponent = ContentComponent_<ContentState>
class ContentComponent_<Lol>: Few.Component<ContentState> {
	var eventMonitor: AnyObject?

	let logout: () -> ()

	init(logoutFn: () -> ()) {
		logout = logoutFn
		let initialState = ContentState(todos: (1...100).map { "Todo #\($0)" }, like: false, watcherCount: nil, selectedIndex: nil)
		super.init(render: ContentComponent.render, initialState: initialState)
	}

	required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let component = copy as ContentComponent
		logout = component.logout
		eventMonitor = component.eventMonitor
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
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
				self.updateState { ContentState(todos: $0.todos, like: $0.like, watcherCount: watchers, selectedIndex: $0.selectedIndex) }
			}
		}

		eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { [unowned self] event in
			self.handleEvent(event)
		}
	}

	func handleEvent(event: NSEvent) -> NSEvent? {
		let characters = event.charactersIgnoringModifiers! as NSString
		let character = Int(characters.characterAtIndex(0))
		let listView = getView(key: Keys.List)!
		let firstResponder = event.window?.firstResponder as? ViewType
		if let firstResponderView = firstResponder {
			if character == NSDeleteCharacter && (firstResponder == listView || firstResponderView.isDescendantOf(listView)) {
				let state = getState()
				if let index = state.selectedIndex {
					var todos = state.todos
					todos.removeAtIndex(index)

					let selectedIndex = (index <= todos.count && index > 0 ? index - 1 : 0)
					updateState { ContentState(todos: todos, like: $0.like, watcherCount: $0.watcherCount, selectedIndex: selectedIndex) }

					return nil
				}
			}
		}

		return event
	}

	override func componentWillDerealize() {
		NSEvent.removeMonitor <^> eventMonitor
	}

	class func render(c: Few.Component<ContentState>, state: ContentState) -> Element {
		let count = Label(text: "\(state.todos.count)")

		let addTodo: () -> () = {
			c.updateState { ContentState(todos: $0.todos + ["a nu todo"], like: $0.like, watcherCount: $0.watcherCount, selectedIndex: $0.selectedIndex) }
		}
		let button = Button(title: "Add", action: addTodo)

		let likedness = (state.like ? "do" : "donut")
		let statusLabel = Label(text: "I \(likedness) like this.")

		let toggleLikedness: () -> () = {
			c.updateState { ContentState(todos: $0.todos, like: !$0.like, watcherCount: $0.watcherCount, selectedIndex: $0.selectedIndex) }
		}
		let toggleButton = Button(title: "Toggle", action: toggleLikedness).width(54)

		var likesIt = maybe(state.watcherCount, Label(text: "Checking…")) {
			Label(text: "\($0) people like us!!!")
		}
			.hidden(!state.like)

		let updateSelection: Int? -> () = { index in
			c.updateState { ContentState(todos: $0.todos, like: $0.like, watcherCount: $0.watcherCount, selectedIndex: index) }
		}
		let list = TodoList(state.todos, selectedRow: state.selectedIndex, selectionChanged: updateSelection)
			.width(100)
			.height(100)
			.key(Keys.List)

		let component = c as ContentComponent
		let logoutButton = Button(title: "Logout", action: component.logout)
			.width(100)
			.height(23)
		
		let children = [count, button, statusLabel, toggleButton, likesIt, list, logoutButton]
		return Container(children |> leftAlign(16) |> verticalStack(c.frame.size.height, 4))
	}
}
