//
//  Animation.swift
//  Few
//
//  Created by Josh Abernathy on 12/17/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import QuartzCore

public enum TimingFunction {
	case Linear
	case EaseIn
	case EaseInOut
	case EaseOut

	public var mediaTimingFunction: CAMediaTimingFunction {
		switch self {
		case Linear: return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		case EaseIn: return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		case EaseInOut: return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		case EaseOut: return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		}
	}
}

public var Animating: Bool { return _Animating }

private var _Animating: Bool = false

public class Animation: Element {
	private let duration: NSTimeInterval
	private let timingFunction: TimingFunction
	private let element: Element
	private let enabled: Bool

	public init(_ element: Element, duration: NSTimeInterval, timingFunction: TimingFunction, enabled: Bool) {
		self.element = element
		self.duration = duration
		self.timingFunction = timingFunction
		self.enabled = enabled
		super.init(frame: element.frame, key: element.key, hidden: element.hidden, alpha: element.alpha)
	}

	public required init(copy: Element, frame: CGRect, hidden: Bool, alpha: CGFloat, key: String?) {
		let animation = copy as Animation
		duration = animation.duration
		element = animation.element.dynamicType(copy: animation.element, frame: frame, hidden: hidden, alpha: alpha, key: key)
		timingFunction = animation.timingFunction
		enabled = animation.enabled
		super.init(copy: copy, frame: frame, hidden: hidden, alpha: alpha, key: key)
	}

	// MARK: Element

	public override func canDiff(other: Element) -> Bool {
		if !super.canDiff(other) { return false }

		let animation = other as Animation
		return element.canDiff(animation.element)
	}

	public override func applyDiff(view: ViewType, other: Element) {
		let animation = other as Animation
		if enabled {
			_Animating = true
			withAnimation(duration, timingFunction) {
				self.element.applyDiff(view, other: animation.element)
			}
			_Animating = false
		} else {
			element.applyDiff(view, other: animation.element)
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
	final public func animate(duration: NSTimeInterval = 0.3, timingFunction: TimingFunction = .EaseInOut, enabled: Bool = true) -> Animation {
		return Animation(self, duration: duration, timingFunction: timingFunction, enabled: enabled)
	}
}
