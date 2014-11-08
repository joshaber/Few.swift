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
	init(state: LogInState) {
		super.init(render: LogInComponent.render, initialState: state)
	}

	class func render(component: Few.Component<LogInState>, state: LogInState) -> Element {
		let usernameField = Input(initialText: "", placeholder: "Username") { str in
			component.replaceState(LogInState(username: str, password: state.password))
		}

		let passwordField = Input(initialText: "", placeholder: "Password") { str in
			component.replaceState(LogInState(username: state.username, password: str))
		}

		let enabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
		let loginButton = Button(title: "Login", enabled: enabled) {
			println("Login: \(state.username): \(state.password)")
		}

		let layout = verticalStack(12) >-- offset(CGPoint(x: 12, y: 12))
		return Container(children: [usernameField, passwordField, loginButton], layout: layout)
	}
}

class DemoComponent2<S>: Few.Component<DemoState2> {
	init() {
		let initialState = DemoState2(loggedIn: false, logInState: LogInState(username: "", password: ""))
		super.init(render: DemoComponent2.render, initialState: initialState)
	}

	class func render(component: Few.Component<DemoState2>, state: DemoState2) -> Element {
		let login = LogInComponent<LogInState>(state: state.logInState)
		login.sizingBehavior = .Fixed(CGSize(width: 480, height: 360))
		return login
	}
}
