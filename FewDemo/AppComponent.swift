//
//  AppComponent.swift
//  Few
//
//  Created by Josh Abernathy on 10/31/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import Few
import SwiftBox

struct AppState {

}

extension Element {
	func sized(width: CGFloat, _ height: CGFloat) -> Self {
		frame.size.width = width
		frame.size.height = height
		return self
	}

	func margin(edges: Edges) -> Self {
		margin = edges
		return self
	}

	func padding(edges: Edges) -> Self {
		padding = edges
		return self
	}

	func selfAlignment(alignment: SelfAlignment) -> Self {
		selfAlignment = alignment
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
			childAlignment: .Center,
			justification: .Center,
			direction: .Column,
			children: [
				Element(
					direction: .Row,
					frame: CGRect(x: 0, y: 0, width: 175, height: 23),
					children: [
						Label(text: "Username").sized(75, 19),
						Input(text: nil) { _ in }.sized(100, 23),
					]),
				Button(title: "Login") {}.sized(50, 23).selfAlignment(.FlexEnd),
			])
	}
}
