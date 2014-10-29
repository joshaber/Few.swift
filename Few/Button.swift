//
//  Button.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Button: Element {
	private let title: String

	private let trampoline = TargetActionTrampoline()

	public init(title: String, action: () -> ()) {
		self.title = title
		super.init()

		self.trampoline.action = action
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		let otherButton = other as Button
		let button = view as NSButton

		if title != button.title {
			button.title = title
		}

		button.target = trampoline

		super.applyDiff(view, other: other)
	}

	public override func realize() -> ViewType? {
		let button = NSButton(frame: frame)
		button.bezelStyle = .TexturedRoundedBezelStyle
		button.title = title
		button.target = trampoline
		button.action = trampoline.selector
		return button
	}

}
