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

	override func controlTextDidChange(notification: NSNotification) {
		action?()
	}
}

public class Input: Element {
	public var text: String? {
		get {
			return _text
		}
	}

	private var textField: NSTextField?
	
	private var _text: String?
	private var initialText: String?
	private var action: String -> ()

	private let inputDelegate = InputDelegate()

	public convenience init(text: String?, fn: String -> ()) {
		self.init(text: text, initialText: nil, action: fn)
	}

	public convenience init(initialText: String?, fn: String -> ()) {
		self.init(text: nil, initialText: initialText, action: fn)
	}

	public init(text: String?, initialText: String?, action: String -> ()) {
		self._text = text
		self.initialText = initialText
		self.action = action
		super.init()
		
		self.inputDelegate.action = { [unowned self] in
			let stringValue = self.textField!.stringValue
			self._text = stringValue
			self.action(stringValue)
		}
	}

	// MARK: Element
	
	public override func applyDiff(other: Element) {
		let otherInput = other as Input
		textField = otherInput.textField
		textField?.delegate = inputDelegate

		if let text = _text {
			if let otherText = otherInput._text {
				if text != otherText {
					textField?.stringValue = text
				}
			}
		} else {
			_text = otherInput._text
		}

		super.applyDiff(other)
	}
	
	public override func realize(parentView: ViewType) {
		let field = NSTextField(frame: frame)
		field.editable = true
		field.stringValue = _text ?? initialText ?? ""
		field.delegate = inputDelegate
		textField = field
		
		super.realize(parentView)
	}
	
	public override func getContentView() -> ViewType? {
		return textField
	}
}
