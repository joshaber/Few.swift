//
//  Button.swift
//  Few
//
//  Created by Josh Abernathy on 8/1/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Button<S: Equatable, T: Setable where T.ValueType == S>: Element<S, T> {
	private var title: String
	private var frame: CGRect

	private var button: NSButton?

	private let trampoline: TargetActionTrampoline

	private var setable: T?

	public init(frame: CGRect, title: String, fn: S -> S) {
		self.frame = frame
		self.title = title
		self.trampoline = TargetActionTrampoline(action: {

		})
	}

	public override func applyDiff(other: Element<S, T>) {
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

	public override func realize(parentView: NSView, setable: T) {
		let button = NSButton(frame: frame)
		button.bezelStyle = .TexturedRoundedBezelStyle
		button.title = title
		button.target = trampoline
		button.action = trampoline.selector
		self.button = button

		self.setable = setable

		super.realize(parentView, setable: setable)
	}

	public override func getContentView() -> NSView? {
		return button
	}
}
