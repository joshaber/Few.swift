//
//  TargetActionTrampoline.swift
//  Swiftful
//
//  Created by Josh Abernathy on 6/18/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

internal class TargetActionTrampoline: NSObject {
	internal var action: (() -> ())?

	internal let selector = Selector("performAction:")

	internal func performAction(sender: AnyObject?) {
		self.action?()
	}
}
