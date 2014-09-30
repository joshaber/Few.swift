//
//  Element.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public func empty() -> Element {
	return fillRect(NSColor.clearColor())
}

public func frame(rect: CGRect)(element: Element) -> Element {
	element.frame = rect
	return element
}

public class Element {
	public var frame = CGRectZero

	/// The key used to uniquely identify the element among its siblings.
	//
	// TODO: This doesn't *really* need to be a string. Just hashable and 
	// equatable.
	public var key: String?

	private weak var component: Component<Any>?
	
	public init() {}

	/// Can the receiver and the other element be diffed?
	///
	/// The default implementation checks the dynamic types of both objects and
	/// returns `true` only if they are identical. This will be good enough for
	/// most cases.
	public func canDiff(other: Element) -> Bool {
		return other.dynamicType === self.dynamicType
	}

	/// Apply the diff. The receiver should take on any differences between it
	/// and `other`.
	///
	/// This will only be called if `canDiff` returns `true`. Implementations 
	/// should call super.
	public func applyDiff(other: Element) {
		if frame != other.frame {
			frame = other.frame
		}
		
		if let view = getContentView() {
			view.frame = frame
		}
	}

	/// Realize the element in the given component and parent view.
	///
	/// The default implementation adds the content view to `parentView`.
	public func realize<S>(component: Component<S>, parentView: NSView) {
		self.component = getComponent(component)

		parentView.addSubview <^> getContentView()
	}
	
	private func getComponent<S, T>(component: Component<S>) -> Component<T> {
		// Ugh. This shouldn't be necessary.
		//
		// Doing this instead of `unsafeBitCast` because that seems to cause
		// problems down the line when it comes to identity?
		let opaqueComponent = Unmanaged.passRetained(component).toOpaque()
		let castComponent: Component<T> = Unmanaged.fromOpaque(opaqueComponent).takeRetainedValue()
		return castComponent
	}
	
	/// Get the component in which the element has been realized.
	public func getComponent<T>() -> Component<T>? {
		if let component = component {
			return getComponent(component)
		} else {
			return nil
		}
	}

	/// Derealize the element.
	///
	/// The default implemetation removes the content view from its superview.
	public func derealize() {
		getContentView()?.removeFromSuperview()
	}

	/// Get the content view which represents the element.
	public func getContentView() -> NSView? {
		return nil
	}
}

extension Element {
	public func debugQuickLookObject() -> AnyObject? {
		let previewSize = CGSize(width: 512, height: 512)
		let dummyComponent = Component(render: const(self), initialState: 0)
		let dummyView = NSView(frame: CGRect(origin: CGPointZero, size: previewSize))
		realize(dummyComponent, parentView: dummyView)

		var previewImage: NSImage? = nil
		if let view = getContentView() {
			let imageRep = view.bitmapImageRepForCachingDisplayInRect(view.bounds)
			if imageRep == nil { return NSImage(size: previewSize) }

			view.cacheDisplayInRect(view.bounds, toBitmapImageRep: imageRep!)

			var image = NSImage(size: imageRep!.size)
			image.addRepresentation(imageRep!)

			previewImage = image
		}
		
		return previewImage
	}

	public func pre() -> NSImage {
		return debugQuickLookObject()! as NSImage
	}
}
