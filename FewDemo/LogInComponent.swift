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

	required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let component = copy as LogInComponent
		loggedIn = component.loggedIn
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	override func componentDidRealize() {
		let usernameField = self.getView(key: Keys.UsernameField)
		let window = usernameField?.window
		window?.makeFirstResponder(usernameField!)
		super.componentDidRealize()
	}

	class func render(c: Few.Component<LogInState>, state: LogInState) -> Element {
		let usernameField = Input(initialText: "", placeholder: "Username")
			{ str in
				c.updateState {
					let typed = str.utf16Count > 0 ? true : $0.typedUsername
					return LogInState(username: str, password: $0.password, typedUsername: typed, typedPassword: $0.typedPassword)
				}
			}
			.alignTop(c)
			.offsetX(16)
			.offsetY(-16)
			.key(Keys.UsernameField)

		let attributes = [
			NSForegroundColorAttributeName: NSColor.redColor(),
			NSFontAttributeName: NSFont.systemFontOfSize(11),
		]
		let enterUsername = Label(attributedString: NSAttributedString(string: "Enter a username", attributes: attributes))
			.alpha(state.username.utf16Count > 0 || !state.typedUsername ? 0 : 1)
			.alignLeft(usernameField)
			.below(usernameField)
			.animate(enabled: state.username.utf16Count > 0)

		let passwordField = Password(initialText: "", placeholder: "Password")
			{ str in
				c.updateState {
					let typed = str.utf16Count > 0 ? true : $0.typedPassword
					return LogInState(username: $0.username, password: str, typedUsername: $0.typedUsername, typedPassword: typed)
				}
			}
			.alignLeft(usernameField)
			.below(enterUsername)

		let enterPassword = Label(attributedString: NSAttributedString(string: "Enter a password", attributes: attributes))
			.alpha(state.password.utf16Count > 0 || !state.typedPassword ? 0 : 1)
			.alignLeft(passwordField)
			.below(passwordField)
			.animate(enabled: state.password.utf16Count > 0)

		let component = c as LogInComponent
		let enabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
		let loginButton = Button(title: "Login", enabled: enabled)
			{
				component.loggedIn(state.username, state.password)
			}
			.alignRight(passwordField)
			.below(enterPassword)

		return Container(usernameField, enterUsername, passwordField, enterPassword, loginButton)
	}
}
