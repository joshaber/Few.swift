//
//  DemoComponent2.swift
//  Few
//
//  Created by Josh Abernathy on 10/31/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct DemoState2 {
	let loggedIn: Bool = false
	let logInState: LogInState
}

struct LogInState {
	let username: String = ""
	let password: String = ""
}

class LogInComponent<S>: Few.Component<LogInState> {
	init(state: LogInState, loggedIn: (String, String) -> ()) {
		super.init(render: LogInComponent.render(loggedIn), initialState: state)
	}

	class func render(loggedIn: (String, String) -> ())(component: Few.Component<LogInState>, state: LogInState) -> Element {
		let usernameField = Input(initialText: "", placeholder: "Username") { str in
			component.replaceState(LogInState(username: str, password: state.password))
		}
		usernameField.frame.origin = CGPoint(x: 16, y: 100)

		let passwordField = Input(initialText: "", placeholder: "Password") { str in
			component.replaceState(LogInState(username: state.username, password: str))
		}
		passwordField.frame.origin = CGPoint(x: 16, y: 50)

		let enabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
		let loginButton = Button(title: "Login", enabled: enabled) {
			loggedIn(state.username, state.password)
			println("Login: \(state.username): \(state.password)")
		}
		loginButton.frame = CGRect(x: 16, y: 0, width: 100, height: 23)

		let container = Container([usernameField, passwordField, loginButton])
		container.frame.size = CGSize(width: 480, height: 360)
		return container
	}
}

class DemoComponent2<S>: Few.Component<DemoState2> {
	init() {
		let initialState = DemoState2(loggedIn: false, logInState: LogInState(username: "", password: ""))
		super.init(render: DemoComponent2.render, initialState: initialState)
	}

	class func render(component: Few.Component<DemoState2>, state: DemoState2) -> Element {
		if state.loggedIn {
			return DemoComponent1<DemoState1>()
		} else {
			return LogInComponent<LogInState>(state: state.logInState) { username, password in
				component.replaceState(DemoState2(loggedIn: true, logInState: state.logInState))
			}
		}
	}
}
