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

	override func componentDidRealize() {
		let URL = NSURL(string: "https://api.github.com/repos/ReactiveCocoa/ReactiveCocoa")!
		GET(URL) { result in
			if result.JSON == nil {
				println("Error: \(result.error)")
				println("Response: \(result.response)")
				return
			}

			let watchers = result.JSON["watchers_count"] as? Int
			dispatch_async(dispatch_get_main_queue()) {
				self.updateState { ContentState(todos: $0.todos, like: $0.like, watcherCount: watchers, selectedIndex: $0.selectedIndex) }
			}
		}

		eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask, handleEvent)
	}

	func handleEvent(event: NSEvent!) -> NSEvent! {
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
		return Empty()
	}
}
