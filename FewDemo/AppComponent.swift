//
//  AppComponent.swift
//  Few
//
//  Created by Josh Abernathy on 10/31/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few

struct AppState {
	let loggedIn: Bool = false
	let logInState = LogInState()
}

typealias AppComponent = AppComponent_<AppState>
class AppComponent_<Lol>: Few.Component<AppState> {
	init() {
		super.init(render: AppComponent.render, initialState: AppState())
	}

	required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	class func render(component: Few.Component<AppState>, state: AppState) -> Element {
		if state.loggedIn {
			return ContentComponent {
				component.updateState { AppState(loggedIn: false, logInState: $0.logInState) }
			}
		} else {
			return LogInComponent(state: state.logInState) { username, password in
				component.updateState { AppState(loggedIn: true, logInState: $0.logInState) }
			}
		}
	}
}
