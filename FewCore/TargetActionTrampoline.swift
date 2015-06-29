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
		action?()
	}
}

public class TargetActionTrampolineWithSender<T: AnyObject> {
	public var target = TargetActionTrampolineProxy()
	public var selector: Selector {
		return target.selector
	}

	public var action: (T -> ())? {
		get {
			return target.action
		}
		set(newAction) {
			target.action = { obj in
				if let sender = obj as? T {
					newAction?(sender)
				}
			}
		}
	}
}

public class TargetActionTrampolineProxy: NSObject {
	public var action: (AnyObject? -> ())?

	private let selector = Selector("performAction:")

	public func performAction(sender: AnyObject?) {
		action?(sender)
	}
}
