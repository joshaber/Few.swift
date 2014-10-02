//
//  Button.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Button<S>: Element {
	private var title: String
	private var action: Component<S> -> ()

	private var button: NSButton?

	private let trampoline = TargetActionTrampoline()

	public convenience init(title: String, fn: S -> S) {
		self.init(title: title, action: { component in
			void(component.updateState(fn))
		})
	}

	public init(title: String, action: Component<S> -> ()) {
		self.title = title
		self.action = action
		super.init()

		self.trampoline.action = { [unowned self] in
			void(self.action <^> self.getComponent())
		}
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

	public override func realize(component: Component<S>, parentView: NSView) {
		let button = NSButton(frame: frame)
		button.bezelStyle = .TexturedRoundedBezelStyle
		button.title = title
		button.target = trampoline
		button.action = trampoline.selector
		self.button = button

		super.realize(component, parentView: parentView)
	}

	public override func getContentView() -> NSView? {
		return button
	}
}
