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
		case success(result: Double, mangledExpression: String)
		case failure(errorMessage: String)
	}
	
	func evaluate(_ expression: String) -> EvaluationResult {
		var result = 0.0
		var errorMessage: NSString?
		
		let mangledExpression = MuParserWrapper.mangleInputString(expression)
		
		if self.evaluate(mangledExpression, result: &result, errorMessage: &errorMessage) {
			return .success(result: result, mangledExpression: mangledExpression)
		} else {
			return .failure(errorMessage: errorMessage! as String)
		}
	}

	fileprivate static func mangleInputString(_ str: String) -> String {
		func innerMangler(_ str: NSMutableString) -> NSMutableString {
			let mangledString = NSMutableString(string: str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
			
			mangledString.replaceOccurrences(of: "**", with: "^", options: .literal, range: NSRange(location: 0, length: mangledString.length))
			
			mangledString.replaceOccurrences(ofRegex: "^([\\-\\+\\/\\*^])", with: "Prev$1")
			
			mangledString.replaceOccurrences(ofRegex: "([\\d\\)Prev])\\(", with: "$1*(")
			mangledString.replaceOccurrences(ofRegex: "\\)([\\d\\(Prev])", with: ")*$1")
			mangledString.replaceOccurrences(ofRegex: "Prev([\\dPrev]+)", with: "Prev*$1")
			mangledString.replaceOccurrences(ofRegex: "([\\dL]+)Prev", with: "$1*Prev")
			
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
