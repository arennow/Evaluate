//
//  MuParserWrapper.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import Foundation
import Regex

extension MuParserWrapper {
	struct EvaluationResult {
		let result: Double
		let mangledExpression: String
	}
	
	func evaluate(_ expression: String) throws -> EvaluationResult {
		let mangledExpression = MuParserWrapper.mangleInputString(expression)
		
		var result: Double = 0
		try self.evaluate(mangledExpression, result: &result)
		
		return EvaluationResult(result: result, mangledExpression: mangledExpression)
	}

	fileprivate static func mangleInputString(_ str: String) -> String {
		func innerMangler(_ str: String) -> String {
			var outStr = str
			
			outStr = outStr.trimmingCharacters(in: .whitespacesAndNewlines)
			
			outStr = outStr.replacingOccurrences(of: "**", with: "^")
			
			outStr = try! Regex(pattern: "^([\\-\\+\\/\\*^])").replaceAll(in: outStr, with: "P$1")
			outStr = try! Regex(pattern: "([\\d\\)P])\\(").replaceAll(in: outStr, with: "$1*(")
			outStr = try! Regex(pattern: "\\)([\\d\\(P])").replaceAll(in: outStr, with: ")*$1")
			outStr = try! Regex(pattern: "P([\\dP]+)").replaceAll(in: outStr, with: "P*$1")
			outStr = try! Regex(pattern: "([\\dP]+)P").replaceAll(in: outStr, with: "$1*P")
			
			return outStr
		}
		
		var stringToMangle = str
		var first: String?
		var second: String?
		
		repeat {
			first = innerMangler(stringToMangle)
			second = innerMangler(first!)
			
			stringToMangle = second!
		} while (first != second)
		
		return second! as String
	}
}
