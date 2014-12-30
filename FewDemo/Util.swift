//
//  Util.swift
//  Few
//
//  Created by Josh Abernathy on 12/28/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Foundation

func GET(URL: NSURL, fn: (NSDictionary!, NSURLResponse!, NSError!) -> ()) {
	NSURLSession.sharedSession().dataTaskWithURL(URL) { (data, response, error) in
		if data == nil {
			fn(nil, response, error)
			return
		}

		var JSONError: NSError?
		let result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &JSONError) as? NSDictionary
		fn(result, response, JSONError)
	}.resume()
}

func uniqueKey(file: String = __FILE__, line: Int = __LINE__, column: Int = __COLUMN__) -> String {
	return "\(file)+\(line)+\(column)"
}
