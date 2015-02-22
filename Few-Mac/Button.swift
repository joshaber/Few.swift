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

	private let trampoline = TargetActionTrampoline()

	public init(title: String, enabled: Bool = true, action: () -> () = { }) {
		self.title = title
		self.enabled = enabled
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

			button.target = trampoline
		}
	}

	public override func createView() -> ViewType {
		let button = NSButton(frame: frame)
		button.bezelStyle = .TexturedRoundedBezelStyle
		button.title = title
		button.target = trampoline
		button.action = trampoline.selector
		button.enabled = enabled
		return button
	}
}
