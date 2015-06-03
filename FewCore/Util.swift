//
//  Util.swift
//  Few
//
//  Created by Josh Abernathy on 8/6/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

public func const<T, V>(val: T) -> (V -> T) {
	return { _ in val }
}

public func id<T>(val: T) -> T {
	return val
}

public func void<T>(@autoclosure fn: () -> T) {
	fn()
}

infix operator <^> { associativity left }
public func <^><A, B>(f: A -> B, a: A?) -> B? {
	if let x = a {
		return f(x)
	} else {
		return .None
	}
}

public func <^><A, B>(f: A -> B, a: [A]) -> [B] {
	return map(a, f)
}

infix operator <*> { associativity left }
public func <*><A, B>(f: (A -> B)?, a: A?) -> B? {
	if f != nil && a != nil {
		return f!(a!)
	} else {
		return .None
	}
}

public func <*><A, B>(f: [A -> B], a: [A]) -> [B] {
	var results = Array<B>()
	for fn in f {
		for x in a {
			results.append(fn(x))
		}
	}

	return results
}

public func curry<A, B, C>(fn: (A, B) -> C) -> A -> B -> C {
	return { a in
		return { b in
			fn(a, b)
		}
	}
}

public func curry<A, B, C, D>(fn: (A, B, C) -> D) -> A -> B -> C -> D {
	return { a in
		return { b in
			return { c in
				fn(a, b, c)
			}
		}
	}
}

infix operator |> { associativity left }
public func |><A, B>(a: A, f: A -> B) -> B {
	return f(a)
}

public func flip<A, B, C>(fn: (A, B) -> C) -> (B, A) -> C {
	return { b, a in
		return fn(a, b)
	}
}

public func maybe<A, B>(value: A?, @autoclosure none: () -> B, some: A -> B) -> B {
	if let value = value {
		return some(value)
	} else {
		return none()
	}
}

internal func memoryAddress(object: AnyObject) -> String {
	let ptr = Unmanaged<AnyObject>.passUnretained(object).toOpaque()
	return "\(ptr)"
}
