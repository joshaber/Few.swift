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

extension Element {
	func sized(width: CGFloat, _ height: CGFloat) -> Self {
		frame.size.width = width
		frame.size.height = height
		return self
	}
}

typealias AppComponent = AppComponent_<AppState>
class AppComponent_<Lol>: Few.Component<AppState> {
	init() {
		super.init(render: AppComponent.render, initialState: AppState())
	}

	class func render(component: Few.Component<AppState>, state: AppState) -> Element {
		return Element(
			frame: CGRect(x: 0, y: 0, width: 500, height: 500),
			childAlignment: .Center,
			children: [
				Label(text: "hi there").sized(100, 23),
				Button(title: "Click") {}.sized(50, 23),
			])
	}
}
