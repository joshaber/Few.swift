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
	private var title: String

	private var button: NSButton?

	private let trampoline = TargetActionTrampoline()

	public init(title: String, action: () -> ()) {
		self.title = title
		super.init()

		self.trampoline.action = action
	}

	// MARK: Element

	public override func applyDiff(other: Element) {
		let otherButton = other as Button
		button = otherButton.button

		if title != otherButton.title {
			button?.title = title
		}

		button?.target = trampoline

		super.applyDiff(other)
	}

	public override func realize(parentView: ViewType) {
		let button = NSButton(frame: frame)
		button.bezelStyle = .TexturedRoundedBezelStyle
		button.title = title
		button.target = trampoline
		button.action = trampoline.selector
		self.button = button

		super.realize(parentView)
	}

	public override func getContentView() -> ViewType? {
		return button
	}
}
