//
//  TargetActionTrampoline.swift
//  Swiftful
//
//  Created by Josh Abernathy on 6/18/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

public class TargetActionTrampoline: NSObject {
	public var action: (() -> ())?

	public let selector = Selector("performAction:")

	public func performAction(sender: AnyObject?) {
		if action == nil { return }

		self.action!()
	}
}
