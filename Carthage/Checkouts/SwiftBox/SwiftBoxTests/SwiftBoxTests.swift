//
//  SwiftBoxTests.swift
//  SwiftBoxTests
//
//  Created by Josh Abernathy on 2/1/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import Cocoa
import XCTest
import SwiftBox

class SwiftBoxTests: XCTestCase {
    func testDescription() {
		let parent = Node(size: CGSize(width: 300, height: 300),
                    childAlignment: .Center,
					direction: .Row,
                    children: [
			Node(flex: 75,
                 margin: Edges(left: 10, right: 10),
                 size: CGSize(width: 0, height: 100)),
			Node(flex: 15,
				 margin: Edges(right: 10),
                 size: CGSize(width: 0, height: 50)),
			Node(flex: 10,
				 margin: Edges(right: 10),
				 size: CGSize(width: 0, height: 180)),
		])

		let layout = parent.layout()
		XCTAssert(("\(layout)".utf16).count > 0, "Has a description.")
    }

	func testSizeParentBasedOnChildren() {
		let parent = Node(children: [
			Node(size: CGSize(width: 100, height: 200)),
			Node(size: CGSize(width: 300, height: 150)),
		])

		let layout = parent.layout()
		XCTAssertEqual(layout.frame.size, CGSize(width: 300, height: 350));
	}

	func testMeasureIsUsed() {
		let measuredSize = CGSize(width: 123, height: 456)
		let node = Node(measure: { w in
			return measuredSize
		})

		let layout = node.layout()
		XCTAssertEqual(layout.frame.size, measuredSize)
	}

	func testMaxWidthIsUsed() {
		let maxWidth: CGFloat = 345
		var maxWidthGiven: CGFloat = 0
		let node = Node(measure: { w in
			maxWidthGiven = w
			return CGSize(width: 1, height: 1)
		})

		node.layout(maxWidth)
		XCTAssertEqual(maxWidthGiven, maxWidth)
	}
	
	func testUndefinedPoint() {
		XCTAssertFalse(CGPoint.zeroPoint.isUndefined, "ordinary point is not undefined")
		XCTAssert(CGPoint(x: 0, y: Node.Undefined).isUndefined, "detects undefined point.y")
		XCTAssert(CGPoint(x: Node.Undefined, y: 0).isUndefined, "detects undefined point.x")
	}

	func testUndefinedSize() {
		XCTAssertFalse(CGSize.zeroSize.isUndefined, "ordinary size is not undefined")
		XCTAssert(CGSize(width: 0, height: Node.Undefined).isUndefined, "detects undefined size.height")
		XCTAssert(CGSize(width: Node.Undefined, height: 0).isUndefined, "detects undefined size.width")
	}
	
	func testUndefinedRect() {
		XCTAssertFalse(CGRect.infiniteRect.isUndefined, "infinite rect is not undefined")
		XCTAssertFalse(CGRect.nullRect.isUndefined, "null rect is not undefined")
		XCTAssertFalse(CGRect.zeroRect.isUndefined, "zero rect is not undefined")
		XCTAssert(CGRect(x: 0, y: 0, width: Node.Undefined, height: 0).isUndefined, "detects undefined size in rect")
		XCTAssert(CGRect(x: Node.Undefined, y: 0, width: 1, height: 1).isUndefined, "detects undefined origin in rect")
	}
}
