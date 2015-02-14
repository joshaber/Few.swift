//
//  ScrollView.swift
//  Few
//
//  Created by Josh Abernathy on 2/7/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Foundation
import SwiftBox
import AppKit

private class FewScrollView: NSView {
	private let scrollView: NSScrollView
	private let didScroll: CGRect -> ()

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	private init(frame: NSRect, didScroll: CGRect -> ()) {
		self.didScroll = didScroll

		scrollView = NSScrollView(frame: frame)
		scrollView.borderType = .BezelBorder
		scrollView.hasVerticalScroller = true
		scrollView.contentView.postsBoundsChangedNotifications = true

		super.init(frame: frame)

		addSubview(scrollView)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("boundsChanged:"), name: NSViewBoundsDidChangeNotification, object: scrollView.contentView)
	}

	private required init?(coder: NSCoder) {
		fatalError("FewScrollView should not be used in a xib.")
	}

	@objc private func boundsChanged(notification: NSNotification) {
		didScroll(scrollView.contentView.visibleRect)
	}
}

public typealias ScrollView = ScrollView_<[Element]>

private class ScrollViewElement: Element {
	private let didScroll: CGRect -> ()

	private init(_ didScroll: CGRect -> ()) {
		self.didScroll = didScroll
	}

	// MARK: Element

	private override func createView() -> ViewType {
		return FewScrollView(frame: frame, didScroll: didScroll)
	}

	private override func addRealizedChildView(childView: ViewType, selfView: ViewType) {
		let scrollVew = selfView as! FewScrollView
		scrollVew.scrollView.documentView = childView
	}

	private override func realize() -> RealizedElement {
		let realizedElement = super.realize()

		let scrollView = realizedElement.view as! FewScrollView
		let documentView = scrollView.scrollView.documentView as! NSView

		let top = CGPointMake(0, documentView.bounds.size.height);
		documentView.scrollPoint(top)

		return realizedElement
	}
}

internal class ScrollViewContent: Element {
	private let layoutChildren: [Element]

	private init(layoutChildren: [Element]) {
		self.layoutChildren = layoutChildren
	}

	internal override func assembleLayoutNode() -> Node {
		let childNodes = layoutChildren.map { $0.assembleLayoutNode() }
		return Node(size: frame.size, children: childNodes, direction: direction, margin: margin, padding: padding, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
	}

	internal override func applyLayout(layout: Layout) {
		frame = CGRectIntegral(layout.frame)

		for (child, layout) in Zip2(layoutChildren, layout.children) {
			child.applyLayout(layout)
		}
	}
}

public class ScrollView_<LOL>: Component<[Element]> {
	public let elements: [Element]

	public init(_ elements: [Element]) {
		self.elements = elements.reverse()
		super.init(render: ScrollView_.render, initialState: [])
	}

	private class func render(c: Component<[Element]>, visibleElements: [Element]) -> Element {
		let component = c as! ScrollView_

		return ScrollViewElement(component.didScroll)
			.direction(.Column)
			.children([
				ScrollViewContent(layoutChildren: component.elements)
					.children(visibleElements)
					.direction(.Column)
			])
	}

	private func didScroll(visibleRect: CGRect) {
		let visibleElements = elements.filter { CGRectIntersectsRect(visibleRect, $0.frame) }
		updateState { _ in visibleElements }
	}
}
