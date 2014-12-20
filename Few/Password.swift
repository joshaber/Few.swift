//
//  Password.swift
//  Few
//
//  Created by Josh Abernathy on 12/19/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

public class Password: Input {
	public override func realize() -> ViewType? {
		let field = NSSecureTextField(frame: frame)
		field.editable = true
		field.stringValue = text ?? initialText ?? ""
		field.delegate = inputDelegate
		field.enabled = enabled

		let cell = field.cell() as? NSTextFieldCell
		cell?.placeholderString = placeholder ?? ""
		return field
	}
}
