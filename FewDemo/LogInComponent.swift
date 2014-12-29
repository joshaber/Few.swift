//
//  LogInComponent.swift
//  Few
//
//  Created by Josh Abernathy on 12/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct LogInState {
	let username: String = ""
	let password: String = ""
}

extension LogInState: Printable {
	var description: String { return "\(username), \(password)" }
}

typealias LogInComponent = LogInComponent_<LogInState>
class LogInComponent_<Lol>: Few.Component<LogInState> {
	let loggedIn: (String, String) -> ()

	init(state: LogInState, loggedIn: (String, String) -> ()) {
		self.loggedIn = loggedIn
		super.init(render: LogInComponent.render, initialState: state)
	}

	required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let component = copy as LogInComponent
		loggedIn = component.loggedIn
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	class func render(c: Few.Component<LogInState>, state: LogInState) -> Element {
		let usernameField = Input(initialText: "", placeholder: "Username") { str in
			c.updateState { LogInState(username: str, password: $0.password) }
		}.offsetX(16)
		.y(c.frame.size.height).subtractHeight().offsetY(-16)

		let attributes = [
			NSForegroundColorAttributeName: NSColor.redColor(),
			NSFontAttributeName: NSFont.systemFontOfSize(11),
		]
		let enterUsername = Label(attributedString: NSAttributedString(string: "Enter a username", attributes: attributes))
			.alpha(state.username.utf16Count > 0 ? 0 : 1)
			.alignLeft(usernameField)
			.below(usernameField)
			.animate(enabled: state.username.utf16Count > 0)

		let passwordField = Password(initialText: "", placeholder: "Password") { str in
			c.updateState { LogInState(username: $0.username, password: str) }
		}.alignLeft(usernameField)
		.below(enterUsername)

		let enterPassword = Label(attributedString: NSAttributedString(string: "Enter a password", attributes: attributes))
			.alpha(state.password.utf16Count > 0 ? 0 : 1)
			.alignLeft(passwordField)
			.below(passwordField)
			.animate(enabled: state.password.utf16Count > 0)

		let component = c as LogInComponent
		let enabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
		let loginButton = Button(title: "Login", enabled: enabled) {
			component.loggedIn(state.username, state.password)
		}.alignRight(passwordField)
		.below(enterPassword)

		return Container(usernameField, enterUsername, passwordField, enterPassword, loginButton)
	}
}
