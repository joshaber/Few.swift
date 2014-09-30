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
	
	private var text: String
	private var action: (String, Component<S>) -> ()
	
	private let inputDelegate = InputDelegate()

	public convenience init(text: String, fn: (String, S) -> S) {
		self.init(text: text, action: { str, component in
			component.updateState { state in
				fn(str, state)
			}
			return ()
		})
	}

	public init(text: String, action: (String, Component<S>) -> ()) {
		self.text = text
		self.action = action
		super.init()
		
		self.inputDelegate.action = { [unowned self] in
			self.text = self.textField!.stringValue
			let component: Component<S>? = self.getComponent()
			if component != nil {
				self.action(stringValue, component!)
			}
		}
	}

	// MARK: Element
	
	public override func applyDiff(other: Element) {
		if textField == nil { return }
		
		let otherInput = other as Input
		if text != otherInput.text {
			text = otherInput.text
			textField!.stringValue = text
		}

		action = otherInput.action

		super.applyDiff(other)
	}
	
	public override func realize(component: Component<S>, parentView: NSView) {
		let field = NSTextField(frame: frame)
		field.editable = true
		field.stringValue = text
		field.delegate = inputDelegate
		textField = field
		
		super.realize(component, parentView: parentView)
	}
	
	public override func getContentView() -> NSView? {
		return textField
	}
}
