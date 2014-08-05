//
//  Button.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Button<S: Equatable>: Element<S> {
	private var title: String
	private var frame: CGRect

	private var button: NSButton?

	private let trampoline = TargetActionTrampoline()

	private weak var component: Component<S>?

	public convenience init(frame: CGRect, title: String, fn: S -> S) {
		self.init(frame: frame, title: title, action: { component in
			component.state = fn(component.state)
		})
	}

	public init(frame: CGRect, title: String, action: Component<S> -> ()) {
		self.frame = frame
		self.title = title
		super.init()

		self.trampoline.action = { [unowned self] in
			if self.component == nil { return }

			action(self.component!)
		}
	}

	public override func applyDiff(other: Element<S>) {
		if button == nil { return }

		let otherButton = other as Button
		let b = button!
		if title != otherButton.title {
			title = otherButton.title
			b.title = title
		}

		if frame != otherButton.frame {
			frame = otherButton.frame
			b.frame = frame
		}
	}

	public override func realize(component: Component<S>, parentView: NSView) {
		self.component = component

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
