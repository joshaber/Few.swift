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
	public func applyDiff(view: ViewType, other: Element) {
		frame = view.frame

		if LogDiff {
			println("** Diffing \(reflect(self).summary)")
		}
	}

	/// Realize the element and return the view containing it.
	public func realize() -> ViewType? {
		return nil
	}

	/// Derealize the element.
	public func derealize() {}
}

extension Element {
	public func debugQuickLookObject() -> AnyObject? {
		let previewSize = CGSize(width: 512, height: 512)
		let view = realize()

		var previewImage: NSImage? = nil
		if let view = view {
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
