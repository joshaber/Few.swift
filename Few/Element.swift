//
//  Element.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import AppKit

public typealias ViewType = NSView

public var LogDiff = false

public func frame<E: Element>(rect: CGRect)(element: E) -> E {
	element.frame = rect
	return element
}

public func size<E: Element>(size: CGSize)(element: E) -> E {
	element.frame.size = size
	return element
}

/// Elements are the basic building block. They represent a visual thing which 
/// can be diffed with other elements.
public class Element {
	/// The frame of the element.
	public var frame = CGRectZero

	/// The key used to identify the element. Elements with matching keys will 
	/// be more readily diffed in certain situations (i.e., when in a Container
	/// or List).
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

	/// Apply the diff. The receiver is the latest version and the argument is
	/// the previous version.
	///
	/// That usually means copying over anything UI-specific from the old 
	/// version to the new version.
	///
	/// This will only be called if `canDiff` returns `true`. Implementations
	/// should call super.
	public func applyDiff(other: Element) {
		if let view = getContentView() {
			frame = view.frame
		}

		component = other.component

		if LogDiff {
			println("** Diffing \(reflect(self).summary)")
		}
	}

	/// Realize the element in the given component and parent view.
	///
	/// The default implementation adds the content view to `parentView`.
	public func realize<S>(component: Component<S>, parentView: ViewType) {
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
	public func getContentView() -> ViewType? {
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
