//
//  Atom.swift
//  Few
//
//  Created by Josh Abernathy on 8/23/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

public class Atom<S> {
	private var value: S {
		didSet {
			for observer in observers {
				observer(value)
			}
		}
	}
	
	private var observers: [S -> ()]
	
	public init(value: S) {
		self.value = value
		self.observers = Array()
	}
	
	public func addObserver(observer: S -> ()) {
		observers.append(observer)
	}
	
	private func removeObserver(observerToRemove: S -> ()) {
		// LOL
	}
}
