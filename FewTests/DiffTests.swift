//
//  DiffTests.swift
//  FewTests
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Quick
import Nimble
import Few

class DiffTests: QuickSpec {
	override func spec() {
		describe("diffElementLists") {
			let button = Button(title: "Hi") {}
			let realizedButton = button.realize(nil)
			let label = Label("Hey").size(100, 23)

			it("should detect simple diffing") {
				let diff = diffElementLists([ realizedButton ], newList: [ button ])
				expect(diff.add.count).to(equal(0))
				expect(diff.remove.count).to(equal(0))
				expect(diff.diff.count).to(equal(1))
			}

			it("should detect replacement") {
				let diff = diffElementLists([ realizedButton ], newList: [ label ])
				expect(diff.add.count).to(equal(1))
				expect(diff.remove.count).to(equal(1))
				expect(diff.diff.count).to(equal(0))
			}

			it("should detect removal") {
				let diff = diffElementLists([ realizedButton ], newList: [])
				expect(diff.add.count).to(equal(0))
				expect(diff.remove.count).to(equal(1))
				expect(diff.diff.count).to(equal(0))
			}

			it("should detect addition") {
				let diff = diffElementLists([ realizedButton ], newList: [ button, label ])
				expect(diff.add.count).to(equal(1))
				expect(diff.remove.count).to(equal(0))
				expect(diff.diff.count).to(equal(1))
			}

			it("should use keys to match even when position changes") {
				let realizedLabel = label.realize(nil)

				let newLabel = Label("No.")
				newLabel.key = "key"
				let diff = diffElementLists([ realizedButton, realizedLabel ], newList: [ button, newLabel, label ])
				expect(diff.add.count).to(equal(1))
				expect(diff.remove.count).to(equal(0))
				expect(diff.diff.count).to(equal(2))
			}
		}
	}
}
