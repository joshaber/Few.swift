//
//  Input.swift
//  Few
//
//  Created by Josh Abernathy on 9/4/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

internal class InputDelegate: NSObject, NSTextFieldDelegate {
	var action: (NSTextField -> ())?

	override func controlTextDidChange(notification: NSNotification) {
		let field = notification.object as! NSTextField
		action?(field)
	}
}

public class Input: Element {
	public var text: String?
	public var initialText: String?
	public var placeholder: String?
	public var enabled: Bool
	public var action: String -> ()

	/// If true then the input will always force its value to be `text` even 
	// while the input is being edited. If false, it will only set the value to
	/// `text` when the input isn't being edited.
	public var forceValueWhileEditing: Bool

	internal let inputDelegate = InputDelegate()

	public init(text: String? = nil, initialText: String? = nil, placeholder: String? = nil, enabled: Bool = true, forceValueWhileEditing: Bool = false, action: String -> () = { _ in }) {
		self.text = text
		self.initialText = initialText
		self.placeholder = placeholder
		self.action = action
		self.enabled = enabled
		self.forceValueWhileEditing = forceValueWhileEditing
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 23))
		
		self.inputDelegate.action = { [unowned self] field in
			self.action(field.stringValue)
		}
	}

	// MARK: Element
	
	public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		super.applyDiff(old, realizedSelf: realizedSelf)

		if let textField = realizedSelf?.view as? NSTextField {
			textField.delegate = inputDelegate

			let cell = textField.cell() as? NSTextFieldCell
			cell?.placeholderString = placeholder ?? ""

			if let text = text {
				var firstResponder = false
				if let firstResponderTextView = textField.window?.firstResponder as? NSTextView {
					firstResponder = firstResponderTextView.delegate === textField
				} else {
					firstResponder = false
				}

				if text != textField.stringValue && !firstResponder && !forceValueWhileEditing {
					textField.stringValue = text
				}
			}

			if enabled != textField.enabled {
				textField.enabled = enabled
			}
		}
	}
	
	public override func createView() -> ViewType {
		let field = NSTextField(frame: CGRectZero)
		field.editable = true
		field.stringValue = text ?? initialText ?? ""
		field.delegate = inputDelegate
		field.enabled = enabled
		field.alphaValue = alpha
		field.hidden = hidden

		let cell = field.cell() as? NSTextFieldCell
		cell?.placeholderString = placeholder ?? ""
		return field
	}
}
