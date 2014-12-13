//
//  Layout.swift
//  Few
//
//  Created by Josh Abernathy on 12/3/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation
import LlamaKit
import Cartography

public struct Properties {
	public var width: CGFloat
	public var height: CGFloat
	public var alphaValue: CGFloat
	public var color: NSColor?
}

public enum Direction {
	case Up, Down, Left, Right
}

public enum PrimitiveElement {
	case Container(position: Position, element: Box<Element2>)
	case Flow(direction: Direction, elements: Box<Array<Element2>>)
	case Space
}

public struct Element2 {
	public var properties: Properties
	let element: PrimitiveElement
}

func width(el: Element2) -> CGFloat {
	return el.properties.width
}

func height(el: Element2) -> CGFloat {
	return el.properties.height
}

func withHeight(height: CGFloat, el: Element2) -> Element2 {
	var el2 = el
	el2.properties.height = height
	
	return el2
}

func withWidth(width: CGFloat, el: Element2) -> Element2 {
	var el2 = el
	el2.properties.width = width

	return el2
}

func withSize(size: CGSize, el: Element2) -> Element2 {
	return withHeight(size.height, withWidth(size.width, el))
}

func size(#el: Element2) -> CGSize {
	return CGSize(width: CGFloat(width(el)), height: CGFloat(height(el)))
}

func makeView(el: Element2) -> NSView {
	let elem = el.element
	switch elem {
	case .Space: return emptyView()
	case let .Container(position, element): return containerView(position, element.unbox)
	case let .Flow(direction, elements): return flowView(direction, elements.unbox)
	}
}

func emptyView() -> NSView {
	return NSView(frame: CGRectZero)
}

func flowView(direction: Direction, elements: Array<Element2>) -> NSView {
	var container = makeView(empty())
	
	var prev: NSView? = nil
	for element in elements {
		let view = render(element)
		
		let flowEdge: (Direction, LayoutProxy) -> Edge = { direction, v in
			switch direction {
			case .Down: return v.top
			case .Up: return v.bottom
			case .Left: return v.trailing
			case .Right: return v.leading
			}
		}
		
		container.addSubview(view)
		
		if prev == nil {
			layout(view) { proxy in
				flowEdge(direction, proxy.superview!) == flowEdge(direction, proxy)
				return // HAHA SWIFT
			}
		} else {
			layout(prev!, view) { prev, view in
				flowEdge(reverseDir(direction), prev) == flowEdge(direction, view)
				return // HAHA SWIFT
			}
		}
		
		prev = view
	}
	
	return container
}

func reverseDir(direction: Direction) -> Direction {
	switch direction {
	case .Up: return .Down
	case .Down: return .Up
	case .Left: return .Right
	case .Right: return .Left
	}
}

public func flow(direction: Direction, elements: Array<Element2>) -> Element2 {
	let widths = map(elements, width)
	let heights = map(elements, height)
	let newFlow = { width, height in
		newElement(width, height, .Flow(direction: direction, elements: Box(elements)))
	}
	
	if (elements.count == 0) {
		return empty()
	}
	
	switch direction {
	case .Up: fallthrough
	case .Down: return newFlow(maximum(widths)!, sum(heights))
	case .Left: fallthrough
	case .Right: return newFlow(sum(widths), maximum(heights)!)
	}
}

public func scanl<B, T>(start:B, list:[T], r:(B, T) -> B) -> [B] {
	if list.isEmpty {
		return []
	}
	var arr = [B]()
	arr.append(start)
	var reduced = start
	for x in list {
		reduced = r(reduced, x)
		arr.append(reduced)
	}
	return Array(arr)
}

func sum(array: Array<CGFloat>) -> CGFloat {
	return foldRight(array)(z: 0, f: +)
}

func maximum<T: Comparable>(array: Array<T>) -> T? {
	return foldRight1(max)(array: array)
}

func max<T: Comparable>(x: T)(y: T) -> T {
	return max(x, y)
}

func foldRight1<A>(f: (A, A) -> A)(#array: Array<A>) -> A? {
	if (array.count == 0) {
		return nil
	}

	var copy = array
	copy.removeAtIndex(0)
	
	return foldRight(copy)(z: array[0], f: f)
}

public func foldRight<T, U>(array: Array<T>)(z: U, f: (T, U) -> U) -> U {
	var res = z
	for x in array {
		res = f(x, res)
	}
	return res
}

public func newElement(width: CGFloat, height: CGFloat, element: PrimitiveElement) -> Element2 {
	let properties = Properties(width: width, height: height, alphaValue: 1, color: nil)
	return Element2(properties: properties, element: element)
}

/// Mutates the given view with the element's properties.
///
/// Returns the mutated view.
func setProperties(element: Element2, view: NSView) -> NSView {
	let properties = element.properties
	let primitiveElement = element.element
	
	view.alphaValue = properties.alphaValue
	
	layout(view) { view in
		view.width == Float(width(element))
		view.height == Float(height(element))
		return
	}
	
	return view
}

public func render(element: Element2) -> NSView {
	return setProperties(element, makeView(element))
}

/// Returns a container view with `element` rendered at `point`.
func containerView(position: Position, element: Element2) -> NSView {
	var view = render(element)
	view = setPosition(position, element, view)
	
	return view
}

enum Horizontal {
	case Leading, Middle, Trailing
}

enum Vertical {
	case Top, Middle, Bottom
}

/// TODO: We can totally do relative positioning
//enum Pos {
//	case Absolute(Int)
//	case Relative(Float)
//}

public struct Position {
	let horizontal: Horizontal
	let vertical: Vertical
	let x: Float
	let y: Float
}


func setPosition(position: Position, element: Element2, view: NSView) -> NSView {
	let primitiveElement = element.element
	let width = element.properties.width
	let height = element.properties.height

	layout(view) { view in
		switch (position.horizontal) {
		case .Leading: view.leading == view.superview!.leading + position.x
		// TODO: Should Middle take `Pos.x` into account?
		case .Middle: view.centerX == view.superview!.centerX
		case .Trailing: view.trailing == view.superview!.trailing - position.x
		}

		switch (position.vertical) {
		case .Top: view.top == view.superview!.top - position.y
		case .Middle: view.centerY == view.superview!.centerY
		case .Bottom: view.bottom == view.superview!.bottom + position.y
		}
	}
	
	return view
}

func empty() -> Element2 {
	return spacer(0, 0)
}

func spacer(width: CGFloat, height: CGFloat) -> Element2 {
	return newElement(width, height, .Space)
}

enum LayoutF<R> {
	case Beside(left: Box<R>, right: Box<R>)
	case Above(top: Box<R>, bottom: Box<R>)
	case Container(rect: CGRect, r: Box<R>)
	case Embed(el: Element)
}

struct Layout<S> {
	let layoutF: LayoutF<Layout<S>>
	let el: Element
	let state: S

	init(layoutF: LayoutF<Layout<S>>, el: Element, state: S) {
		self.layoutF = layoutF
		self.el = el
		self.state = state
	}
}

func map<A, B>(f: A -> B, l: Layout<A>) -> Layout<B> {
	let newF: LayoutF<Layout<B>> = {
		switch l.layoutF {
		case let .Beside(r, r2):
			let left: Box<Layout<B>> = Box(map(f, r.unbox))
			let right: Box<Layout<B>> = Box(map(f, r.unbox))
			return .Beside(left: left, right: right)
		case let .Above(r, r2):
			return .Above(top: Box(map(f, r.unbox)), bottom: Box(map(f, r2.unbox)))
		case let .Container(rect, r):
			return .Container(rect: rect, r: Box(map(f, r.unbox)))
		case let .Embed(el):
			return .Embed(el: el)
		}
	}()

	return Layout(layoutF: newF, el: l.el, state: f(l.state))
}

func element<S>(#l: Layout<S>) -> Element {
	return l.el
}

func transform<S>(f: Element -> Element, #l: Layout<S>) -> Layout<S> {
	return Layout(layoutF: l.layoutF, el: f(l.el), state: l.state)
}

public func leftAlign(x: CGFloat)(elements: [Element]) -> [Element] {
	for element in elements {
		element.frame.origin.x = x
	}

	return elements
}

public func verticalStack(top: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	var y = top
	for element in elements {
		if element.hidden { continue }

		y -= element.frame.size.height + padding
		element.frame.origin.y = y
	}

	return elements
}

public func horizontalStack(left: CGFloat, padding: CGFloat)(elements: [Element]) -> [Element] {
	var x = left
	for element in elements {
		if element.hidden { continue }

		x += element.frame.size.width + padding
		element.frame.origin.x = x
	}

	return elements
}

public func offset(x: CGFloat, y: CGFloat)(elements: [Element]) -> [Element] {
	for element in elements {
		element.frame.origin.x += x
		element.frame.origin.y += y
	}

	return elements
}
