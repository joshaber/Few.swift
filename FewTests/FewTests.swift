//
//  FewTests.swift
//  FewTests
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Quick
import Nimble

class FewTests: QuickSpec {
	override func spec() {
		it("is truthy") {
			expect(true).to(beTruthy())
		}
	}
}
