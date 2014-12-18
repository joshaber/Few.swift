//
//  Animation.swift
//  Few
//
//  Created by Josh Abernathy on 12/17/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import QuartzCore

public var Animating: Bool { return _Animating }

private var _Animating: Bool = false

public class Animation: Element {
	private let duration: NSTimeInterval
	private let timingFunction: CAMediaTimingFunction
	private let element: Element

	public init(_ element: Element, duration: NSTimeInterval, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)) {
		self.element = element
		self.duration = duration
		self.timingFunction = timingFunction
		super.init(frame: element.frame, key: element.key, hidden: element.hidden, alpha: element.alpha)
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, key: String?, alpha: CGFloat) {
		let animation = copy as Animation
		duration = animation.duration
		element = animation.element.dynamicType(copy: animation.element, frame: frame, hidden: hidden, key: key, alpha: alpha)
		timingFunction = animation.timingFunction
		super.init(copy: copy, frame: frame, hidden: hidden, key: key, alpha: alpha)
	}

	// MARK: Element

	public override func canDiff(other: Element) -> Bool {
		return super.canDiff(other) || element.canDiff(other)
	}

	public override func applyDiff(view: ViewType, other: Element) {
		if let animation = other as? Animation {
			_Animating = true
			withAnimation(duration, timingFunction) {
				self.element.applyDiff(view, other: animation.element)
			}
			_Animating = false
		} else {
			element.applyDiff(view, other: other)
		}
	}

	public override func realize() -> ViewType? {
		return element.realize()
	}

	public override func derealize() {
		element.derealize()
	}

	public override func getChildren() -> [Element] {
		return element.getChildren()
	}
}

extension Element {
	public func animate() -> Animation {
		return Animation(self, duration: 0.3)
	}
}
