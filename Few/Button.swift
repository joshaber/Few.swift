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

	private let trampoline: TargetActionTrampoline

	public init(frame: CGRect, title: String, fn: S -> S) {
		self.frame = frame
		self.title = title
		self.trampoline = TargetActionTrampoline(action: {

		})
	}

	public override func applyDiff(other: Element<S>) {
		if !button.getLogicValue() {
			return
		}

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

	public override func realize(parentView: NSView, component: Component<S>) {
		let button = NSButton(frame: frame)
		button.bezelStyle = .TexturedRoundedBezelStyle
		button.title = title
		button.target = trampoline
		button.action = trampoline.selector
		self.button = button

		super.realize(parentView, component: component)
	}

	public override func getContentView() -> NSView? {
		return button
	}
}
