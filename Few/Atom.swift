//
//  Atom.swift
//  Few
//
//  Created by Josh Abernathy on 8/23/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

public class Atom<S> {
	private let queue = dispatch_queue_create("Few.Atom.queue", 0)
	
	private var value: S {
		didSet {
			for observer in observers {
				// TODO: Really shouldn't notify observers while holding a lock.
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
		dispatch_sync(queue) {
			self.observers.append(observer)
		}
	}
	
	private func removeObserver(observerToRemove: S -> ()) {
		// LOL
	}
	
	public func apply(fn: S -> S) -> S {
		var newValue = value
		dispatch_sync(queue) {
			newValue = fn(self.value)
			self.value = newValue
		}
		
		return newValue
	}
}
