//
//  Password.swift
//  Few
//
//  Created by Josh Abernathy on 12/19/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public class Password: Input {
	public override func createView() -> ViewType {
		let field = NSSecureTextField(frame: CGRectZero)
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
