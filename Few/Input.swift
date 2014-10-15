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

	private var _textField: NSTextField?
	
	private var _text: String?
	private var initialText: String?
	private var placeholder: String?
	private var action: String -> ()

	private let inputDelegate = InputDelegate()

	public convenience init(text: String?, fn: String -> ()) {
		self.init(text: text, initialText: nil, placeholder: nil, action: fn)
	}

	public convenience init(initialText: String?, placeholder: String?, fn: String -> ()) {
		self.init(text: nil, initialText: initialText, placeholder: placeholder, action: fn)
	}

	public init(text: String?, initialText: String?, placeholder: String?, action: String -> ()) {
		self._text = text
		self.initialText = initialText
		self.placeholder = placeholder
		self.action = action
		super.init()
		
		self.inputDelegate.action = { [unowned self] in
			let stringValue = self._textField!.stringValue
			self._text = stringValue
			self.action(stringValue)
		}
	}

	public var textField: NSTextField? {
		return _textField
	}

	// MARK: Element
	
	public override func applyDiff(other: Element) {
		let otherInput = other as Input
		_textField = otherInput._textField
		_textField?.delegate = inputDelegate

		let cell = _textField?.cell() as? NSTextFieldCell
		cell?.placeholderString = placeholder ?? ""

		if let text = _text {
			if let otherText = otherInput._text {
				if text != otherText {
					_textField?.stringValue = text
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

		let cell = field.cell() as? NSTextFieldCell
		cell?.placeholderString = placeholder ?? ""

		_textField = field
		
		super.realize(parentView)
	}
	
	public override func getContentView() -> ViewType? {
		return _textField
	}
}
