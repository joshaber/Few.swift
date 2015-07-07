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
	public var title: String
	public var enabled: Bool
	public var isDefault: Bool
	public var bezelStyle: NSBezelStyle

	private let trampoline = TargetActionTrampoline()

	public init(title: String, enabled: Bool = true, isDefault: Bool = false, bezelStyle: NSBezelStyle = .TexturedRoundedBezelStyle, action: () -> () = { }) {
		self.title = title
		self.enabled = enabled
		self.isDefault = isDefault
		self.bezelStyle = bezelStyle
		
		super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 23))

		self.trampoline.action = action
	}

	// MARK: Element

	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		if let button = realizedSelf?.view as? NSButton {
			if title != button.title {
				button.title = title
			}

			if enabled != button.enabled {
				button.enabled = enabled
			}

			let oldButton = old as! Button
			if isDefault != oldButton.isDefault {
				if isDefault {
					button.keyEquivalent = "\r"
				} else {
					button.keyEquivalent = ""
				}
			}

			if bezelStyle != button.bezelStyle {
				button.bezelStyle = bezelStyle
			}

			button.target = trampoline
		}
	}

	public override func createView() -> ViewType {
		let button = NSButton(frame: CGRectZero)
		button.bezelStyle = .TexturedRoundedBezelStyle
		button.title = title
		button.target = trampoline
		button.action = trampoline.selector
		button.enabled = enabled
		button.alphaValue = alpha
		button.hidden = hidden
		if isDefault { button.keyEquivalent = "\r" }
		return button
	}
}
