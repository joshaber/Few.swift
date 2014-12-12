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
	private let enabled: Bool

	private let trampoline = TargetActionTrampoline()

	public convenience init(title: String, action: () -> ()) {
		self.init(title: title, enabled: true, action: action)
	}

	public init(title: String, enabled: Bool, action: () -> ()) {
		self.title = title
		self.enabled = enabled
		super.init()

		self.frame.size = CGSize(width: 50, height: 23)
		self.trampoline.action = action
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, key: String?) {
	    let button = copy as Button
		title = button.title
		enabled = button.enabled
		trampoline = button.trampoline
		super.init(copy: copy, frame: frame, hidden: hidden, key: key)
	}

	// MARK: Element

	public override func applyDiff(view: ViewType, other: Element) {
		let otherButton = other as Button
		let button = view as NSButton

		if title != button.title {
			button.title = title
		}

		if enabled != button.enabled {
			button.enabled = enabled
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
