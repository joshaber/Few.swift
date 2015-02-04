//
//  LogInComponent.swift
//  Few
//
//  Created by Josh Abernathy on 12/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few
import SwiftBox

struct LogInState {
	let username: String = ""
	let password: String = ""
	let typedUsername: Bool = false
	let typedPassword: Bool = false
}

extension LogInState: Printable {
	var description: String { return "\(username), \(password)" }
}

private struct Keys {
	static let UsernameField = uniqueKey()
}

typealias LogInComponent = LogInComponent_<LogInState>
class LogInComponent_<Lol>: Few.Component<LogInState> {
	let loggedIn: (String, String) -> ()

	init(state: LogInState, loggedIn: (String, String) -> ()) {
		self.loggedIn = loggedIn
		super.init(render: LogInComponent.render, initialState: state)
	}

	override func componentDidRealize() {
		let usernameField = self.getView(key: Keys.UsernameField)
		let window = usernameField?.window
		window?.makeFirstResponder(usernameField!)
		super.componentDidRealize()
	}

	class func render(c: Few.Component<LogInState>, state: LogInState) -> Element {
		let label = Label(text: "Hi there")
		label.frame.size.width = 100
		label.frame.size.height = 23

		let button = Button(title: "Click") {}
		button.frame.size.width = 50
		button.frame.size.height = 23

		return label + button
	}
}
