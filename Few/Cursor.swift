////
////  File.swift
////  Few
////
////  Created by Josh Abernathy on 8/29/14.
////  Copyright (c) 2014 Josh Abernathy. All rights reserved.
////
//
//import Foundation
//
//public class Cursor<S, T> {
//	private let getFn: T -> S
//	private let setFn: S -> T
//	
//	private var observers: [S -> ()] = Array()
//
//	public init(get: T -> S, set: S -> T) {
//		getFn = get
//		setFn = set
//	}
//	
//	public func get(val: T) -> S {
//		return getFn(val)
//	}
//	
//	public func set(val: S) {
//		setFn(val)
//		notify(val)
//	}
//	
//	public func makeCursor<T>(get: S -> T, set: T -> T) -> Cursor<T> {
//		let trueGet = { get(self.get()) }
//		let cursor = Cursor<T>(get: trueGet, set: set)
//		cursor.addObserver { val in
//			
//		}
//		return cursor
//	}
//	
//	public func addObserver(fn: S -> ()) {
//		observers.append(fn)
//	}
//	
//	private func notify(val: S) {
//		for observer in observers {
//			observer(val)
//		}
//	}
//}
