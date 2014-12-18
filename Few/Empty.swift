//
//  Empty.swift
//  Few
//
//  Created by Josh Abernathy on 10/2/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

/// An empty element. No view is created or added.
public class Empty: Element {
	public init() {
		super.init()
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}
}
