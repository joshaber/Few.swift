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
	let username: String = ""
	let password: String = ""
}

class DemoComponent2<S>: Few.Component<DemoState2> {
	init() {
		let initialState = DemoState2()
		super.init(render: DemoComponent2.render, initialState: initialState)
	}

	class func render(component: Few.Component<DemoState2>, state: DemoState2) -> Element {
		let usernameField = Input(initialText: "", placeholder: "Username") { str in
			component.replaceState(DemoState2(username: str, password: state.password))
		}

		let passwordField = Input(initialText: "", placeholder: "Password") { str in
			component.replaceState(DemoState2(username: state.username, password: str))
		}

		let enabled = (state.username.utf16Count > 0 && state.password.utf16Count > 0)
		let loginButton = Button(title: "Login", enabled: enabled) {
			println("Login: \(state.username): \(state.password)")
		}

		return Container(children: [usernameField, passwordField, loginButton], layout: verticalStack(12))
	}
}
