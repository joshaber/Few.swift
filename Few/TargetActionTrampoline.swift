//
//  TargetActionTrampoline.swift
//  Swiftful
//
//  Created by Josh Abernathy on 6/18/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

public class TargetActionTrampoline: NSObject {
	public let action: () -> ()

	public let selector = Selector("performAction:")

	public init(action: () -> ()) {
		self.action = action
	}

	public func performAction(sender: AnyObject?) {
		self.action()
	}
}
