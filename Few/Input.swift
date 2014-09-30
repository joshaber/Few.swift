//
//  Input.swift
//  Few
//
//  Created by Josh Abernathy on 9/4/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

private class InputDelegate: NSObject, NSTextFieldDelegate {
	var action: (() -> ())?

	override func controlTextDidChange(notification: NSNotification!) {
		action?();
	}
}

public class Input<S>: Element {
	private var textField: NSTextField?
	
	private var text: String?
	private var initialText: String?
	private var action: (String, Component<S>) -> ()
	
	private let inputDelegate = InputDelegate()

	public convenience init(text: String?, fn: (String, S) -> S) {
		self.init(text: text, initialText: nil, action: { str, component in
			component.updateState { state in
				fn(str, state)
			}
			return ()
		})
	}

	public convenience init(initialText: String?, fn: (String, S) -> S) {
		self.init(text: nil, initialText: initialText, action: { str, component in
			component.updateState { state in
				fn(str, state)
			}
			return ()
		})
	}

	public init(text: String?, initialText: String?, action: (String, Component<S>) -> ()) {
		self.text = text
		self.initialText = initialText
		self.action = action
		super.init()
		
		self.inputDelegate.action = { [unowned self] in
			let stringValue = self.textField!.stringValue
			self.text = stringValue
			let component: Component<S>? = self.getComponent()
			if component != nil {
				self.action(stringValue, component!)
			}
		}
	}

	// MARK: Element
	
	public override func applyDiff(other: Element) {
		let otherInput = other as Input
		if let text = text {
			if let otherText = otherInput.text {
				if text != otherText {
					self.text = otherText
					textField?.stringValue = otherText
				}
			}
		}

		initialText = otherInput.initialText
		action = otherInput.action

		super.applyDiff(other)
	}
	
	public override func realize(component: Component<S>, parentView: NSView) {
		let field = NSTextField(frame: frame)
		field.editable = true
		field.stringValue = text ?? initialText ?? ""
		field.delegate = inputDelegate
		textField = field
		
		super.realize(component, parentView: parentView)
	}
	
	public override func getContentView() -> NSView? {
		return textField
	}
}
