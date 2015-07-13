//
//  Element.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import CoreGraphics

public var LogDiff = false

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

	/// Is the element hidden?
	public var hidden: Bool = false

	/// The alpha for the element.
	public var alpha: CGFloat = 1

	// On OS X we have to reverse our children since the default coordinate 
	// system is flipped.
	public var children: [Element] {
		didSet {
#if os(OSX)
			if direction == .Column {
				children = children.reverse()
			}
#endif
		}
	}

#if os(OSX)
	public var direction: Direction {
		didSet {
			if direction != oldValue {
				children = children.reverse()
			}
		}
	}
#else
	public var direction: Direction
#endif

	public var margin: Edges
	public var padding: Edges
	public var wrap: Bool
	public var justification: Justification
	public var selfAlignment: SelfAlignment
	public var childAlignment: ChildAlignment
	public var flex: CGFloat

	/// Should the input make itself the focus after it's been realized?
	public var autofocus: Bool

	public init(frame: CGRect = CGRect(x: 0, y: 0, width: Node.Undefined, height: Node.Undefined), key: String? = nil, hidden: Bool = false, alpha: CGFloat = 1, autofocus: Bool = false, children: [Element] = [], direction: Direction = .Row, margin: Edges = Edges(), padding: Edges = Edges(), wrap: Bool = false, justification: Justification = .FlexStart, selfAlignment: SelfAlignment = .Auto, childAlignment: ChildAlignment = .Stretch, flex: CGFloat = 0) {
		self.frame = frame
		self.key = key
		self.hidden = hidden
		self.alpha = alpha
		self.autofocus = autofocus
		self.children = children
		self.direction = direction
		self.margin = margin
		self.padding = padding
		self.wrap = wrap
		self.justification = justification
		self.selfAlignment = selfAlignment
		self.childAlignment = childAlignment
		self.flex = flex
	}

	/// Can the receiver and the other element be diffed?
	///
	/// The default implementation checks the dynamic types of both objects and
	/// returns `true` only if they are identical. This will be good enough for
	/// most cases.
	public func canDiff(other: Element) -> Bool {
		return other.dynamicType === self.dynamicType
	}

	/// Apply the diff. The receiver is the latest version and the argument is
	/// the previous version. This usually entails updating the properties of 
	/// the given view when they are different from the properties of the 
	/// receiver.
	///
	/// This will be called as part of the render process, and also immediately
	/// after the element has been realized.
	///
	/// This will only be called if `canDiff` returns `true`. Implementations
	/// should call super before doing their own diffing.
	public func applyDiff(old: Element, realizedSelf: RealizedElement?) {
		if LogDiff {
			println("*** Diffing \(self)")
		}

		if let realizedSelf = realizedSelf {
			realizedSelf.element = self
			
			if let view = realizedSelf.view {
				if hidden != view.hidden {
					view.hidden = hidden
				}
				
				compareAndSetAlpha(view, alpha)
			}
			
			if old.frame.size != frame.size && !frame.size.isUndefined {
				realizedSelf.markNeedsLayout()
			}
			
			let childrenDiff = diffElementLists(realizedSelf.children, children)

			if LogDiff {
				printChildDiff(childrenDiff, old: old)
			}

			for child in childrenDiff.remove {
				child.remove()
				realizedSelf.markNeedsLayout()
			}

			for child in childrenDiff.add {
				let realizedChild = child.realize(realizedSelf)
				realizedSelf.markNeedsLayout()
			}

			for child in childrenDiff.diff {
				child.replacement.applyDiff(child.existing.element, realizedSelf: child.existing)
			}
		}
	}

	private final func printChildDiff(diff: ElementListDiff, old: Element) {
		if old.children.count == 0 && children.count == 0 { return }

		let oldChildren = old.children.map { "\($0.dynamicType)" }
		println("**** old: \(oldChildren)")

		let newChildren = children.map { "\($0.dynamicType)" }
		println("**** new: \(newChildren)")

		for d in diff.diff {
			println("**** applying \(d.replacement.dynamicType) => \(d.existing.element.dynamicType)")
		}

		let removing = diff.remove.map { "\($0.element.dynamicType)" }
		println("**** removing \(removing)")

		let adding = diff.add.map { "\($0.dynamicType)" }
		println("**** adding \(adding)")
		println()
	}

	public func createView() -> ViewType? {
		return nil
	}

	public func createRealizedElement(view: ViewType?, parent: RealizedElement?) -> RealizedElement {
		return RealizedElement(element: self, view: view, parent: parent)
	}

	/// Realize the element.
	public func realize(parent: RealizedElement?) -> RealizedElement {
		let view = createView()

		let realizedSelf = createRealizedElement(view, parent: parent)
		parent?.addRealizedChild(realizedSelf, index: indexOfObject(children, self))

		for child in children {
			child.realize(realizedSelf)
		}

		return realizedSelf
	}

	/// Derealize the element.
	public func derealize() {}

	public func assembleLayoutNode() -> Node {
		let childNodes = children.map { $0.assembleLayoutNode() }

		return Node(size: frame.size, children: childNodes, direction: direction, margin: marginWithPlatformSpecificAdjustments, padding: paddingWithPlatformSpecificAdjustments, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
	}

	private final func verticallyFlippedEdges(edges: Edges) -> Edges {
		return Edges(left: edges.left, right: edges.right, top: edges.bottom, bottom: edges.top)
	}

	internal final var marginWithPlatformSpecificAdjustments: Edges {
#if os(OSX)
		return verticallyFlippedEdges(margin)
#else
		return margin
#endif
	}

	internal final var paddingWithPlatformSpecificAdjustments: Edges {
#if os(OSX)
		return verticallyFlippedEdges(padding)
#else
		return padding
#endif
	}

	internal var selfDescription: String {
		return "\(self.dynamicType)"
	}

	public func elementDidRealize(realizedSelf: RealizedElement) {
		if autofocus {
#if os(OSX)
			realizedSelf.view?.window!.makeFirstResponder(realizedSelf.view)
#else
			realizedSelf.view?.becomeFirstResponder()
#endif
		}
	}

	internal var isRoot: Bool {
		return false
	}

	internal var isRendering: Bool {
		return false
	}

	internal var isRenderQueued: Bool {
		return false
	}

	/// Called after the element and all its children have been layed out.
	public func elementDidLayout(realizedSelf: RealizedElement?) {}
}

extension Element {
	public func size(width: CGFloat, _ height: CGFloat) -> Self {
		frame.size.width = width
		frame.size.height = height
		return self
	}

	public func width(w: CGFloat) -> Self {
		frame.size.width = w
		return self
	}

	public func height(h: CGFloat) -> Self {
		frame.size.height = h
		return self
	}

	public func margin(edges: Edges) -> Self {
		margin = edges
		return self
	}

	public func padding(edges: Edges) -> Self {
		padding = edges
		return self
	}

	public func selfAlignment(alignment: SelfAlignment) -> Self {
		selfAlignment = alignment
		return self
	}

	public func direction(d: Direction) -> Self {
		direction = d
		return self
	}

	public func wrap(w: Bool) -> Self {
		wrap = w
		return self
	}

	public func justification(j: Justification) -> Self {
		justification = j
		return self
	}

	public func childAlignment(alignment: ChildAlignment) -> Self {
		childAlignment = alignment
		return self
	}

	public func flex(f: CGFloat) -> Self {
		flex = f
		return self
	}

	public func frame(f: CGRect) -> Self {
		frame = f
		return self
	}

	public func hidden(h: Bool) -> Self {
		hidden = h
		return self
	}

	public func children(c: [Element]) -> Self {
		children = c
		return self
	}

	public func alpha(a: CGFloat) -> Self {
		alpha = a
		return self
	}

	public func autofocus(f: Bool) -> Self {
		autofocus = f
		return self
	}
}

extension Element: Printable {
	public var description: String {
		return descriptionForDepth(0)
	}

	private func descriptionForDepth(depth: Int) -> String {
		if children.count > 0 {
			let indentation = reduce(0...depth, "\n") { accum, _ in accum + "\t" }
			let childrenDescription = indentation.join(children.map { $0.descriptionForDepth(depth + 1) })
			return "\(selfDescription)\(indentation)\(childrenDescription)"
		} else {
			return selfDescription
		}
	}
}
