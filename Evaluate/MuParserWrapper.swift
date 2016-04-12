//
//  MuParserWrapper.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import Foundation
import RegexKitLite

extension MuParserWrapper {
	enum EvaluationResult {
		case Success(result: Double, mangledExpression: String)
		case Failure(errorMessage: String)
	}
	
	func evaluate(expression: String) -> EvaluationResult {
		var result = 0.0
		var errorMessage: NSString?
		
		let mangledExpression = MuParserWrapper.mangleInputString(expression)
		
		if self.evaluate(mangledExpression, result: &result, errorMessage: &errorMessage) {
			return .Success(result: result, mangledExpression: mangledExpression)
		} else {
			return .Failure(errorMessage: errorMessage! as String)
		}
	}

	private static func mangleInputString(str: String) -> String {
		func innerMangler(str: NSMutableString) -> NSMutableString {
			let mangledString = NSMutableString(string: str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
			
			mangledString.replaceOccurrencesOfString("**", withString: "^", options: .LiteralSearch, range: NSRange(location: 0, length: mangledString.length))
			
			mangledString.replaceOccurrencesOfRegex("^([\\-\\+\\/\\*^])", withString: "L$1")
			
			mangledString.replaceOccurrencesOfRegex("([\\d\\)L])\\(", withString: "$1*(")
			mangledString.replaceOccurrencesOfRegex("\\)([\\d\\(L])", withString: ")*$1")
			mangledString.replaceOccurrencesOfRegex("L([\\dL]+)", withString: "L*$1")
			mangledString.replaceOccurrencesOfRegex("([\\dL]+)L", withString: "$1*L")
			
			return mangledString
		}
		
		let mutStr = NSMutableString(string: str)
		
		var stringToMangle = mutStr
		var first: NSMutableString?
		var second: NSMutableString?
		
		repeat {
			first = innerMangler(stringToMangle)
			second = innerMangler(first!)
			
			stringToMangle = second!
		} while (first != second)
		
		return second! as String
	}
}